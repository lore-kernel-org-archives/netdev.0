From: Claudio Imbrenda <imbrenda@linux.vnet.ibm.com>
Subject: [PATCH v2 0/2] AF_VSOCK: Shrink the area influenced by prepare_to_wait
Date: Thu, 17 Mar 2016 17:12:34 +0100
Message-ID: <1458231156-18845-1-git-send-email-imbrenda@linux.vnet.ibm.com>
Cc: labbott@fedoraproject.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: davem@davemloft.net
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

I'm resending as requested.
This patchset applies on net-next.

And sorry for the mis-formatting of the previous message.


Claudio Imbrenda (2):
  Revert "vsock: Fix blocking ops call in prepare_to_wait"
  AF_VSOCK: Shrink the area influenced by prepare_to_wait

 net/vmw_vsock/af_vsock.c | 155 ++++++++++++++++++++++++++---------------------
 1 file changed, 87 insertions(+), 68 deletions(-)

-- 
1.9.1
