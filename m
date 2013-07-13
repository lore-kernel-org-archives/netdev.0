From: Dragos Foianu <dragos.foianu@gmail.com>
Subject: [PATCH] net/irda: fixed style issues in irlan_eth
Date: Sat, 13 Jul 2013 15:03:55 +0100
Message-ID: <1373724235-25655-1-git-send-email-dragos.foianu@gmail.com>
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	Dragos Foianu <dragos.foianu@gmail.com>
To: samuel@sortiz.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ea0-f181.google.com ([209.85.215.181]:45524 "EHLO
	mail-ea0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751367Ab3GMMED (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 13 Jul 2013 08:04:03 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Applied fixes suggested by checkpatch.pl

Signed-off-by: Dragos Foianu <dragos.foianu@gmail.com>
---
 net/irda/irlan/irlan_eth.c |   31 ++++++++++++++-----------------
 1 file changed, 14 insertions(+), 17 deletions(-)

diff --git a/net/irda/irlan/irlan_eth.c b/net/irda/irlan/irlan_eth.c
index d14152e..ffcec22 100644
--- a/net/irda/irlan/irlan_eth.c
+++ b/net/irda/irlan/irlan_eth.c
@@ -44,12 +44,12 @@ static int  irlan_eth_open(struct net_device *dev);
 static int  irlan_eth_close(struct net_device *dev);
 static netdev_tx_t  irlan_eth_xmit(struct sk_buff *skb,
 					 struct net_device *dev);
-static void irlan_eth_set_multicast_list( struct net_device *dev);
+static void irlan_eth_set_multicast_list(struct net_device *dev);
 
 static const struct net_device_ops irlan_eth_netdev_ops = {
-	.ndo_open               = irlan_eth_open,
-	.ndo_stop               = irlan_eth_close,
-	.ndo_start_xmit    	= irlan_eth_xmit,
+	.ndo_open		= irlan_eth_open,
+	.ndo_stop		= irlan_eth_close,
+	.ndo_start_xmit		= irlan_eth_xmit,
 	.ndo_set_rx_mode	= irlan_eth_set_multicast_list,
 	.ndo_change_mtu		= eth_change_mtu,
 	.ndo_validate_addr	= eth_validate_addr,
@@ -110,7 +110,7 @@ static int irlan_eth_open(struct net_device *dev)
 {
 	struct irlan_cb *self = netdev_priv(dev);
 
-	IRDA_DEBUG(2, "%s()\n", __func__ );
+	IRDA_DEBUG(2, "%s()\n", __func__);
 
 	/* Ready to play! */
 	netif_stop_queue(dev); /* Wait until data link is ready */
@@ -137,7 +137,7 @@ static int irlan_eth_close(struct net_device *dev)
 {
 	struct irlan_cb *self = netdev_priv(dev);
 
-	IRDA_DEBUG(2, "%s()\n", __func__ );
+	IRDA_DEBUG(2, "%s()\n", __func__);
 
 	/* Stop device */
 	netif_stop_queue(dev);
@@ -310,35 +310,32 @@ static void irlan_eth_set_multicast_list(struct net_device *dev)
 {
 	struct irlan_cb *self = netdev_priv(dev);
 
-	IRDA_DEBUG(2, "%s()\n", __func__ );
+	IRDA_DEBUG(2, "%s()\n", __func__);
 
 	/* Check if data channel has been connected yet */
 	if (self->client.state != IRLAN_DATA) {
-		IRDA_DEBUG(1, "%s(), delaying!\n", __func__ );
+		IRDA_DEBUG(1, "%s(), delaying!\n", __func__);
 		return;
 	}
 
 	if (dev->flags & IFF_PROMISC) {
 		/* Enable promiscuous mode */
 		IRDA_WARNING("Promiscuous mode not implemented by IrLAN!\n");
-	}
-	else if ((dev->flags & IFF_ALLMULTI) ||
+	} else if ((dev->flags & IFF_ALLMULTI) ||
 		 netdev_mc_count(dev) > HW_MAX_ADDRS) {
 		/* Disable promiscuous mode, use normal mode. */
-		IRDA_DEBUG(4, "%s(), Setting multicast filter\n", __func__ );
+		IRDA_DEBUG(4, "%s(), Setting multicast filter\n", __func__);
 		/* hardware_set_filter(NULL); */
 
 		irlan_set_multicast_filter(self, TRUE);
-	}
-	else if (!netdev_mc_empty(dev)) {
-		IRDA_DEBUG(4, "%s(), Setting multicast filter\n", __func__ );
+	} else if (!netdev_mc_empty(dev)) {
+		IRDA_DEBUG(4, "%s(), Setting multicast filter\n", __func__);
 		/* Walk the address list, and load the filter */
 		/* hardware_set_filter(dev->mc_list); */
 
 		irlan_set_multicast_filter(self, TRUE);
-	}
-	else {
-		IRDA_DEBUG(4, "%s(), Clearing multicast filter\n", __func__ );
+	} else {
+		IRDA_DEBUG(4, "%s(), Clearing multicast filter\n", __func__);
 		irlan_set_multicast_filter(self, FALSE);
 	}
 
-- 
1.7.10.4
