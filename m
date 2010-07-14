From: Chihau Chau <chihau@gmail.com>
Subject: [PATCH] Net: ethernet: eth: fix some code style issues
Date: Wed, 14 Jul 2010 16:22:17 -0400
Message-ID: <1279138937-12985-1-git-send-email-chihau@gmail.com>
Cc: eric.dumazet@gmail.com, opurdila@ixiacom.com,
	netdev@vger.kernel.org, linux-devel@vger.kernel.org,
	mitov@issp.bas.bg, Chihau Chau <chihau@gmail.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gy0-f174.google.com ([209.85.160.174]:52306 "EHLO
	mail-gy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751404Ab0GNUWY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 Jul 2010 16:22:24 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Chihau Chau <chihau@gmail.com>

This fixes to include <linux/uaccess.h> instead <asm/uaccess.h> and some
code style issues like space before close parenthesis and space before
tabs.

Signed-off-by: Chihau Chau <chihau@gmail.com>
---
 net/ethernet/eth.c |    7 ++++---
 1 files changed, 4 insertions(+), 3 deletions(-)

diff --git a/net/ethernet/eth.c b/net/ethernet/eth.c
index 61ec032..25ccce0 100644
--- a/net/ethernet/eth.c
+++ b/net/ethernet/eth.c
@@ -58,7 +58,7 @@
 #include <net/ipv6.h>
 #include <net/ip.h>
 #include <net/dsa.h>
-#include <asm/uaccess.h>
+#include <linux/uaccess.h>
 #include <asm/system.h>
 
 __setup("ether=", netdev_boot_setup);
@@ -180,7 +180,8 @@ __be16 eth_type_trans(struct sk_buff *skb, struct net_device *dev)
 	 *      seems to set IFF_PROMISC.
 	 */
 
-	else if (1 /*dev->flags&IFF_PROMISC */ ) {
+	/*dev->flags&IFF_PROMISC */
+	else if (1) {
 		if (unlikely(compare_ether_addr_64bits(eth->h_dest, dev->dev_addr)))
 			skb->pkt_type = PACKET_OTHERHOST;
 	}
@@ -338,7 +339,7 @@ void ether_setup(struct net_device *dev)
 {
 	dev->header_ops		= &eth_header_ops;
 	dev->type		= ARPHRD_ETHER;
-	dev->hard_header_len 	= ETH_HLEN;
+	dev->hard_header_len	= ETH_HLEN;
 	dev->mtu		= ETH_DATA_LEN;
 	dev->addr_len		= ETH_ALEN;
 	dev->tx_queue_len	= 1000;	/* Ethernet wants good queues */
-- 
1.5.6.3

