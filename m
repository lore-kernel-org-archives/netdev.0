From: Phil Sutter <phil@nwl.cc>
Subject: [PATCH 04/21] net: loopback: convert to using IFF_NO_QUEUE
Date: Tue, 18 Aug 2015 10:30:32 +0200
Message-ID: <1439886649-24166-5-git-send-email-phil@nwl.cc>
References: <1439886649-24166-1-git-send-email-phil@nwl.cc>
 <1439886649-24166-2-git-send-email-phil@nwl.cc>
 <1439886649-24166-3-git-send-email-phil@nwl.cc>
 <1439886649-24166-4-git-send-email-phil@nwl.cc>
Cc: brouer@redhat.com, davem@davemloft.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from orbit.nwl.cc ([176.31.251.142]:51357 "EHLO mail.nwl.cc"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751778AbbHRIax (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 18 Aug 2015 04:30:53 -0400
In-Reply-To: <1439886649-24166-4-git-send-email-phil@nwl.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Phil Sutter <phil@nwl.cc>
---
 drivers/net/loopback.c | 3 +--
 1 file changed, 1 insertion(+), 2 deletions(-)

diff --git a/drivers/net/loopback.c b/drivers/net/loopback.c
index c76283c..dc7d970 100644
--- a/drivers/net/loopback.c
+++ b/drivers/net/loopback.c
@@ -165,10 +165,9 @@ static void loopback_setup(struct net_device *dev)
 	dev->mtu		= 64 * 1024;
 	dev->hard_header_len	= ETH_HLEN;	/* 14	*/
 	dev->addr_len		= ETH_ALEN;	/* 6	*/
-	dev->tx_queue_len	= 0;
 	dev->type		= ARPHRD_LOOPBACK;	/* 0x0001*/
 	dev->flags		= IFF_LOOPBACK;
-	dev->priv_flags		|= IFF_LIVE_ADDR_CHANGE;
+	dev->priv_flags		|= IFF_LIVE_ADDR_CHANGE | IFF_NO_QUEUE;
 	netif_keep_dst(dev);
 	dev->hw_features	= NETIF_F_ALL_TSO | NETIF_F_UFO;
 	dev->features 		= NETIF_F_SG | NETIF_F_FRAGLIST
-- 
2.1.2
