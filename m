From: Peter Zijlstra <a.p.zijlstra@chello.nl>
Subject: [PATCH] cleanup of the NETIF_F_* flag definitions
Date: Sat, 12 Aug 2006 21:24:06 +0200
Message-ID: <1155410647.13508.119.camel@lappy>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from amsfep17-int.chello.nl ([213.46.243.15]:6313 "EHLO
	amsfep16-int.chello.nl") by vger.kernel.org with ESMTP
	id S964941AbWHLTYz (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 12 Aug 2006 15:24:55 -0400
To: netdev@vger.kernel.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Cleanup the NETIF_F_ flag definitions

Signed-off-by: Peter Zijlstra <a.p.zijlstra@chello.nl>

---
 include/linux/netdevice.h |   26 ++++++++++++++------------
 1 file changed, 14 insertions(+), 12 deletions(-)

Index: linux-2.6/include/linux/netdevice.h
===================================================================
--- linux-2.6.orig/include/linux/netdevice.h
+++ linux-2.6/include/linux/netdevice.h
@@ -298,18 +298,20 @@ struct net_device
 
 	/* Net device features */
 	unsigned long		features;
-#define NETIF_F_SG		1	/* Scatter/gather IO. */
-#define NETIF_F_IP_CSUM		2	/* Can checksum only TCP/UDP over IPv4. */
-#define NETIF_F_NO_CSUM		4	/* Does not require checksum. F.e. loopack. */
-#define NETIF_F_HW_CSUM		8	/* Can checksum all the packets. */
-#define NETIF_F_HIGHDMA		32	/* Can DMA to high memory. */
-#define NETIF_F_FRAGLIST	64	/* Scatter/gather IO. */
-#define NETIF_F_HW_VLAN_TX	128	/* Transmit VLAN hw acceleration */
-#define NETIF_F_HW_VLAN_RX	256	/* Receive VLAN hw acceleration */
-#define NETIF_F_HW_VLAN_FILTER	512	/* Receive filtering on VLAN */
-#define NETIF_F_VLAN_CHALLENGED	1024	/* Device cannot handle VLAN packets */
-#define NETIF_F_GSO		2048	/* Enable software GSO. */
-#define NETIF_F_LLTX		4096	/* LockLess TX */
+#define NETIF_F_SG		0x0001	/* Scatter/gather IO. */
+#define NETIF_F_IP_CSUM		0x0002	/* Can checksum only TCP/UDP over IPv4. */
+#define NETIF_F_NO_CSUM		0x0004	/* Does not require checksum. F.e. loopack. */
+#define NETIF_F_HW_CSUM		0x0008	/* Can checksum all the packets. */
+
+#define NETIF_F_HIGHDMA		0x0010	/* Can DMA to high memory. */
+#define NETIF_F_FRAGLIST	0x0020	/* Scatter/gather IO. */
+#define NETIF_F_HW_VLAN_TX	0x0040	/* Transmit VLAN hw acceleration */
+#define NETIF_F_HW_VLAN_RX	0x0080	/* Receive VLAN hw acceleration */
+
+#define NETIF_F_HW_VLAN_FILTER	0x0100	/* Receive filtering on VLAN */
+#define NETIF_F_VLAN_CHALLENGED	0x0200	/* Device cannot handle VLAN packets */
+#define NETIF_F_GSO		0x0400	/* Enable software GSO. */
+#define NETIF_F_LLTX		0x0800	/* LockLess TX */
 
 	/* Segmentation offload features */
 #define NETIF_F_GSO_SHIFT	16


