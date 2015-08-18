From: Phil Sutter <phil@nwl.cc>
Subject: [PATCH 08/21] net: 8021q: convert to using IFF_NO_QUEUE
Date: Tue, 18 Aug 2015 10:30:36 +0200
Message-ID: <1439886649-24166-9-git-send-email-phil@nwl.cc>
References: <1439886649-24166-1-git-send-email-phil@nwl.cc>
 <1439886649-24166-2-git-send-email-phil@nwl.cc>
 <1439886649-24166-3-git-send-email-phil@nwl.cc>
 <1439886649-24166-4-git-send-email-phil@nwl.cc>
 <1439886649-24166-5-git-send-email-phil@nwl.cc>
 <1439886649-24166-6-git-send-email-phil@nwl.cc>
 <1439886649-24166-7-git-send-email-phil@nwl.cc>
 <1439886649-24166-8-git-send-email-phil@nwl.cc>
Cc: brouer@redhat.com, davem@davemloft.net,
	Patrick McHardy <kaber@trash.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from orbit.nwl.cc ([176.31.251.142]:39580 "EHLO mail.nwl.cc"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751827AbbHRIay (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 18 Aug 2015 04:30:54 -0400
In-Reply-To: <1439886649-24166-8-git-send-email-phil@nwl.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Phil Sutter <phil@nwl.cc>
Cc: Patrick McHardy <kaber@trash.net>
---
 net/8021q/vlan_dev.c | 3 +--
 1 file changed, 1 insertion(+), 2 deletions(-)

diff --git a/net/8021q/vlan_dev.c b/net/8021q/vlan_dev.c
index 01d7ba8..fded865 100644
--- a/net/8021q/vlan_dev.c
+++ b/net/8021q/vlan_dev.c
@@ -791,10 +791,9 @@ void vlan_setup(struct net_device *dev)
 {
 	ether_setup(dev);
 
-	dev->priv_flags		|= IFF_802_1Q_VLAN;
+	dev->priv_flags		|= IFF_802_1Q_VLAN | IFF_NO_QUEUE;
 	dev->priv_flags		&= ~IFF_TX_SKB_SHARING;
 	netif_keep_dst(dev);
-	dev->tx_queue_len	= 0;
 
 	dev->netdev_ops		= &vlan_netdev_ops;
 	dev->destructor		= vlan_dev_free;
-- 
2.1.2
