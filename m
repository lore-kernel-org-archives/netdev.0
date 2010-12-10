From: Shirley Ma <mashirle@us.ibm.com>
Subject: [RFC PATCH V2 2/5] Add a new device flag for zero copy
Date: Fri, 10 Dec 2010 01:57:55 -0800
Message-ID: <1291975075.2167.31.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: xiaohui.xin@intel.com, netdev@vger.kernel.org, kvm@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Avi Kivity <avi@redhat.com>, Arnd Bergmann <arnd@arndb.de>,
	mst@redhat.com
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Shirley Ma <xma@us.ibm.com>
---

 include/linux/netdevice.h |    3 +++
 1 files changed, 3 insertions(+), 0 deletions(-)

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index d8fd2c2..7207665 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -857,6 +857,9 @@ struct net_device {
 #define NETIF_F_NTUPLE		(1 << 27) /* N-tuple filters supported */
 #define NETIF_F_RXHASH		(1 << 28) /* Receive hashing offload */
 
+/* bit 29 is for device to map userspace buffers -- zerocopy */
+#define NETIF_F_ZEROCOPY	(1 << 29)	
+
 	/* Segmentation offload features */
 #define NETIF_F_GSO_SHIFT	16
 #define NETIF_F_GSO_MASK	0x00ff0000
