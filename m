From: Phil Sutter <phil@nwl.cc>
Subject: [PATCH 02/21] net: dummy: convert to using IFF_NO_QUEUE
Date: Tue, 18 Aug 2015 10:30:30 +0200
Message-ID: <1439886649-24166-3-git-send-email-phil@nwl.cc>
References: <1439886649-24166-1-git-send-email-phil@nwl.cc>
 <1439886649-24166-2-git-send-email-phil@nwl.cc>
Cc: brouer@redhat.com, davem@davemloft.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from orbit.nwl.cc ([176.31.251.142]:60208 "EHLO mail.nwl.cc"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750950AbbHRIav (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 18 Aug 2015 04:30:51 -0400
In-Reply-To: <1439886649-24166-2-git-send-email-phil@nwl.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Phil Sutter <phil@nwl.cc>
---
 drivers/net/dummy.c | 3 +--
 1 file changed, 1 insertion(+), 2 deletions(-)

diff --git a/drivers/net/dummy.c b/drivers/net/dummy.c
index 49adbf1..815eb94 100644
--- a/drivers/net/dummy.c
+++ b/drivers/net/dummy.c
@@ -144,10 +144,9 @@ static void dummy_setup(struct net_device *dev)
 	dev->destructor = free_netdev;
 
 	/* Fill in device structure with ethernet-generic values. */
-	dev->tx_queue_len = 0;
 	dev->flags |= IFF_NOARP;
 	dev->flags &= ~IFF_MULTICAST;
-	dev->priv_flags |= IFF_LIVE_ADDR_CHANGE;
+	dev->priv_flags |= IFF_LIVE_ADDR_CHANGE | IFF_NO_QUEUE;
 	dev->features	|= NETIF_F_SG | NETIF_F_FRAGLIST | NETIF_F_TSO;
 	dev->features	|= NETIF_F_HW_CSUM | NETIF_F_HIGHDMA | NETIF_F_LLTX;
 	eth_hw_addr_random(dev);
-- 
2.1.2
