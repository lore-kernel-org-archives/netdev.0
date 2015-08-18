From: Phil Sutter <phil@nwl.cc>
Subject: [PATCH 03/21] net: geneve: convert to using IFF_NO_QUEUE
Date: Tue, 18 Aug 2015 10:30:31 +0200
Message-ID: <1439886649-24166-4-git-send-email-phil@nwl.cc>
References: <1439886649-24166-1-git-send-email-phil@nwl.cc>
 <1439886649-24166-2-git-send-email-phil@nwl.cc>
 <1439886649-24166-3-git-send-email-phil@nwl.cc>
Cc: brouer@redhat.com, davem@davemloft.net,
	"John W. Linville" <linville@tuxdriver.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from orbit.nwl.cc ([176.31.251.142]:38104 "EHLO mail.nwl.cc"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751725AbbHRIaw (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 18 Aug 2015 04:30:52 -0400
In-Reply-To: <1439886649-24166-3-git-send-email-phil@nwl.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Phil Sutter <phil@nwl.cc>
Cc: John W. Linville <linville@tuxdriver.com>
---
 drivers/net/geneve.c | 3 +--
 1 file changed, 1 insertion(+), 2 deletions(-)

diff --git a/drivers/net/geneve.c b/drivers/net/geneve.c
index 78d49d1..897e1a3 100644
--- a/drivers/net/geneve.c
+++ b/drivers/net/geneve.c
@@ -283,7 +283,6 @@ static void geneve_setup(struct net_device *dev)
 
 	SET_NETDEV_DEVTYPE(dev, &geneve_type);
 
-	dev->tx_queue_len = 0;
 	dev->features    |= NETIF_F_LLTX;
 	dev->features    |= NETIF_F_SG | NETIF_F_HW_CSUM;
 	dev->features    |= NETIF_F_RXCSUM;
@@ -297,7 +296,7 @@ static void geneve_setup(struct net_device *dev)
 	dev->hw_features |= NETIF_F_HW_VLAN_CTAG_TX | NETIF_F_HW_VLAN_STAG_TX;
 
 	netif_keep_dst(dev);
-	dev->priv_flags |= IFF_LIVE_ADDR_CHANGE;
+	dev->priv_flags |= IFF_LIVE_ADDR_CHANGE | IFF_NO_QUEUE;
 }
 
 static const struct nla_policy geneve_policy[IFLA_GENEVE_MAX + 1] = {
-- 
2.1.2
