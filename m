From: Laura Vasilescu <laura@rosedu.org>
Subject: [PATCH] ethernet: fix checkpatch errors
Date: Tue, 17 Apr 2012 17:27:24 +0300
Message-ID: <1334672844-10129-1-git-send-email-laura@rosedu.org>
Cc: netdev@vger.kernel.org, eric.dumazet@gmail.com,
	nhorman@tuxdriver.com, davem@davemloft.net,
	Laura Vasilescu <laura@rosedu.org>
To: linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f174.google.com ([74.125.82.174]:63942 "EHLO
	mail-we0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752970Ab2DQO1l (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Apr 2012 10:27:41 -0400
Received: by wejx9 with SMTP id x9so4071921wej.19
        for <netdev@vger.kernel.org>; Tue, 17 Apr 2012 07:27:40 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Laura Vasilescu <laura@rosedu.org>
---
 net/ethernet/eth.c |   20 ++++++++++++--------
 1 files changed, 12 insertions(+), 8 deletions(-)

diff --git a/net/ethernet/eth.c b/net/ethernet/eth.c
index bf10a31..5cca0ff 100644
--- a/net/ethernet/eth.c
+++ b/net/ethernet/eth.c
@@ -20,8 +20,8 @@
  *		Alan Cox	: eth_rebuild_header missing an htons and
  *				  minor other things.
  *		Tegge		: Arp bug fixes.
- *		Florian		: Removed many unnecessary functions, code cleanup
- *				  and changes for new arp and skbuff.
+ *		Florian		: Removed many unnecessary functions, code
+ *				  cleanup and changes for new arp and skbuff.
  *		Alan Cox	: Redid header building to reflect new format.
  *		Alan Cox	: ARP only when compiled with CONFIG_INET
  *		Greg Page	: 802.2 and SNAP stuff.
@@ -29,8 +29,9 @@
  *		Paul Gortmaker	: eth_copy_and_sum shouldn't csum padding.
  *		Alan Cox	: Protect against forwarding explosions with
  *				  older network drivers and IFF_ALLMULTI.
- *	Christer Weinigel	: Better rebuild header message.
- *             Andrew Morton    : 26Feb01: kill ether_setup() - use netdev_boot_setup().
+ *		Christer Weinigel: Better rebuild header message.
+ *		Andrew Morton   : 26Feb01: kill ether_setup() -
+ *				  use netdev_boot_setup().
  *
  *		This program is free software; you can redistribute it and/or
  *		modify it under the terms of the GNU General Public License
@@ -178,8 +179,9 @@ __be16 eth_type_trans(struct sk_buff *skb, struct net_device *dev)
 	 *      seems to set IFF_PROMISC.
 	 */
 
-	else if (1 /*dev->flags&IFF_PROMISC */ ) {
-		if (unlikely(compare_ether_addr_64bits(eth->h_dest, dev->dev_addr)))
+	else if (1 /*dev->flags&IFF_PROMISC */) {
+		if (unlikely(compare_ether_addr_64bits(eth->h_dest,
+							dev->dev_addr)))
 			skb->pkt_type = PACKET_OTHERHOST;
 	}
 
@@ -233,7 +235,9 @@ EXPORT_SYMBOL(eth_header_parse);
  * @type: Ethernet type field
  * Create an Ethernet header template from the neighbour.
  */
-int eth_header_cache(const struct neighbour *neigh, struct hh_cache *hh, __be16 type)
+int eth_header_cache(const struct neighbour *neigh,
+			struct hh_cache *hh,
+			__be16 type)
 {
 	struct ethhdr *eth;
 	const struct net_device *dev = neigh->dev;
@@ -336,7 +340,7 @@ void ether_setup(struct net_device *dev)
 {
 	dev->header_ops		= &eth_header_ops;
 	dev->type		= ARPHRD_ETHER;
-	dev->hard_header_len 	= ETH_HLEN;
+	dev->hard_header_len	= ETH_HLEN;
 	dev->mtu		= ETH_DATA_LEN;
 	dev->addr_len		= ETH_ALEN;
 	dev->tx_queue_len	= 1000;	/* Ethernet wants good queues */
-- 
1.7.1
