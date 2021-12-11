#!/bin/bash
# script that runs 
# https://kubernetes.io/docs/setup/production-environment/container-runtime

# setting MYOS variable
MYOS=$(hostnamectl | awk '/Operating/ { print $3 }')
OSVERSION=$(hostnamectl | awk '/Operating/ { print $4 }')

##### RHEL 7 config
	echo setting up RHEL 7 with Docker 
	yum install -y vim yum-utils device-mapper-persistent-data lvm2
	yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo

	# notice that only verified versions of Docker may be installed
	# verify the documentation to check if a more recent version is available

	yum install -y docker-ce
	[ ! -d /etc/docker ] && mkdir /etc/docker

	mkdir -p /etc/systemd/system/docker.service.d


	cat > /etc/docker/daemon.json <<- EOF
	{
	  "exec-opts": ["native.cgroupdriver=systemd"],
	  "log-driver": "json-file",
	  "log-opts": {
	    "max-size": "100m"
	  },
	  "storage-driver": "overlay2",
	  "storage-opts": [
	    "overlay2.override_kernel_check=true"
	  ]
	}
	EOF


	systemctl daemon-reload
	systemctl restart docker
	systemctl enable docker

	systemctl disable --now firewalld

