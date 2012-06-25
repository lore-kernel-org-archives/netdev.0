From: Jason Wang <jasowang@redhat.com>
Subject: [PATCH 3/6] tuntap: introduce multiqueue flags
Date: Mon, 25 Jun 2012 19:59:20 +0800
Message-ID: <1340625563-9300-4-git-send-email-jasowang@redhat.com>
References: <20120625060830.6765.27584.stgit@amd-6168-8-1.englab.nay.redhat.com>
Cc: shemminger@vyatta.com, edumazet@google.com,
	Jason Wang <jasowang@redhat.com>
To: mst@redhat.com, akong@redhat.com, habanero@linux.vnet.ibm.com,
	tahm@linux.vnet.ibm.com, haixiao@juniper.net,
	jwhan@filewood.snu.ac.kr, ernesto.martin@viasat.com,
	mashirle@us.ibm.com, davem@davemloft.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, krkumar2@in.ibm.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20120625060830.6765.27584.stgit@amd-6168-8-1.englab.nay.redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Add flags to be used by creating multiqueue tuntap device.

Signed-off-by: Jason Wang <jasowang@redhat.com>
---
 include/linux/if_tun.h |    2 ++
 1 files changed, 2 insertions(+), 0 deletions(-)

diff --git a/include/linux/if_tun.h b/include/linux/if_tun.h
index 06b1829..c92a291 100644
--- a/include/linux/if_tun.h
+++ b/include/linux/if_tun.h
@@ -34,6 +34,7 @@
 #define TUN_ONE_QUEUE	0x0080
 #define TUN_PERSIST 	0x0100	
 #define TUN_VNET_HDR 	0x0200
+#define TUN_TAP_MQ      0x0400
 
 /* Ioctl defines */
 #define TUNSETNOCSUM  _IOW('T', 200, int) 
@@ -61,6 +62,7 @@
 #define IFF_ONE_QUEUE	0x2000
 #define IFF_VNET_HDR	0x4000
 #define IFF_TUN_EXCL	0x8000
+#define IFF_MULTI_QUEUE 0x0100
 
 /* Features for GSO (TUNSETOFFLOAD). */
 #define TUN_F_CSUM	0x01	/* You can hand me unchecksummed packets. */
-- 
1.7.1
