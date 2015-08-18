From: Phil Sutter <phil@nwl.cc>
Subject: [PATCH 09/21] net: bridge: convert to using IFF_NO_QUEUE
Date: Tue, 18 Aug 2015 10:30:37 +0200
Message-ID: <1439886649-24166-10-git-send-email-phil@nwl.cc>
References: <1439886649-24166-1-git-send-email-phil@nwl.cc>
 <1439886649-24166-2-git-send-email-phil@nwl.cc>
 <1439886649-24166-3-git-send-email-phil@nwl.cc>
 <1439886649-24166-4-git-send-email-phil@nwl.cc>
 <1439886649-24166-5-git-send-email-phil@nwl.cc>
 <1439886649-24166-6-git-send-email-phil@nwl.cc>
 <1439886649-24166-7-git-send-email-phil@nwl.cc>
 <1439886649-24166-8-git-send-email-phil@nwl.cc>
 <1439886649-24166-9-git-send-email-phil@nwl.cc>
Cc: brouer@redhat.com, davem@davemloft.net,
	Stephen Hemminger <stephen@networkplumber.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from orbit.nwl.cc ([176.31.251.142]:43155 "EHLO mail.nwl.cc"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751143AbbHRIaz (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 18 Aug 2015 04:30:55 -0400
In-Reply-To: <1439886649-24166-9-git-send-email-phil@nwl.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Phil Sutter <phil@nwl.cc>
Cc: Stephen Hemminger <stephen@networkplumber.org>
---
 net/bridge/br_device.c | 3 +--
 1 file changed, 1 insertion(+), 2 deletions(-)

diff --git a/net/bridge/br_device.c b/net/bridge/br_device.c
index 0aa8f5c..6ed2feb 100644
--- a/net/bridge/br_device.c
+++ b/net/bridge/br_device.c
@@ -365,8 +365,7 @@ void br_dev_setup(struct net_device *dev)
 	dev->destructor = br_dev_free;
 	dev->ethtool_ops = &br_ethtool_ops;
 	SET_NETDEV_DEVTYPE(dev, &br_type);
-	dev->tx_queue_len = 0;
-	dev->priv_flags = IFF_EBRIDGE;
+	dev->priv_flags = IFF_EBRIDGE | IFF_NO_QUEUE;
 
 	dev->features = COMMON_FEATURES | NETIF_F_LLTX | NETIF_F_NETNS_LOCAL |
 			NETIF_F_HW_VLAN_CTAG_TX | NETIF_F_HW_VLAN_STAG_TX;
-- 
2.1.2
