From: Christian Borntraeger <borntraeger@de.ibm.com>
Subject: [PATCH 0/1] vhost, use_mm and KERNEL_DS
Date: Tue, 26 Jun 2012 12:59:57 +0200
Message-ID: <1340708398-17965-1-git-send-email-borntraeger@de.ibm.com>
Cc: kvm@vger.kernel.org, netdev@vger.kernel.org,
	Jens Freimann <jfrei@linux.vnet.ibm.com>,
	Christian Borntraeger <borntraeger@de.ibm.com>
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <kvm-owner@vger.kernel.org>
Sender: kvm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Folks,

here is a patch that fixes vhost to use USER_DS before
doing a use_mm/usercopy operation. This was found during
vhost prototyping on s390 were we have a separate user/kernel
address space.


Jens Freimann (1):
  use USER_DS in vhost_worker thread

 drivers/vhost/vhost.c |    3 +++
 1 files changed, 3 insertions(+), 0 deletions(-)

