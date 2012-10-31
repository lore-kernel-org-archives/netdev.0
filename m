From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: [PATCH] veth: allow changing the mac address while interface is up
Date: Wed, 31 Oct 2012 03:22:01 +0100
Message-ID: <20121031022201.GH18860@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:52774 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932069Ab2JaC2x (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 30 Oct 2012 22:28:53 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
---
 drivers/net/veth.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/drivers/net/veth.c b/drivers/net/veth.c
index 5852361..9f87718 100644
--- a/drivers/net/veth.c
+++ b/drivers/net/veth.c
@@ -264,6 +264,7 @@ static void veth_setup(struct net_device *dev)
 	ether_setup(dev);
 
 	dev->priv_flags &= ~IFF_TX_SKB_SHARING;
+	dev->priv_flags |= IFF_LIVE_ADDR_CHANGE;
 
 	dev->netdev_ops = &veth_netdev_ops;
 	dev->ethtool_ops = &veth_ethtool_ops;
