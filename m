From: Phil Sutter <phil@nwl.cc>
Subject: [PATCH net-next 2/2] openvswitch: Convert to using IFF_NO_QUEUE
Date: Fri, 15 Apr 2016 19:14:20 +0200
Message-ID: <1460740460-12859-3-git-send-email-phil@nwl.cc>
References: <1460740460-12859-1-git-send-email-phil@nwl.cc>
Cc: netdev@vger.kernel.org, Pravin Shelar <pshelar@nicira.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from orbyte.nwl.cc ([151.80.46.58]:58038 "EHLO mail.nwl.cc"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753006AbcDOROk (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 15 Apr 2016 13:14:40 -0400
In-Reply-To: <1460740460-12859-1-git-send-email-phil@nwl.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Cc: Pravin Shelar <pshelar@nicira.com>
Signed-off-by: Phil Sutter <phil@nwl.cc>
---
 net/openvswitch/vport-internal_dev.c | 3 +--
 1 file changed, 1 insertion(+), 2 deletions(-)

diff --git a/net/openvswitch/vport-internal_dev.c b/net/openvswitch/vport-internal_dev.c
index 7c8b90bf0e540..2ee48e447b724 100644
--- a/net/openvswitch/vport-internal_dev.c
+++ b/net/openvswitch/vport-internal_dev.c
@@ -165,11 +165,10 @@ static void do_setup(struct net_device *netdev)
 
 	netdev->priv_flags &= ~IFF_TX_SKB_SHARING;
 	netdev->priv_flags |= IFF_LIVE_ADDR_CHANGE | IFF_OPENVSWITCH |
-			      IFF_PHONY_HEADROOM;
+			      IFF_PHONY_HEADROOM | IFF_NO_QUEUE;
 	netdev->destructor = internal_dev_destructor;
 	netdev->ethtool_ops = &internal_dev_ethtool_ops;
 	netdev->rtnl_link_ops = &internal_dev_link_ops;
-	netdev->tx_queue_len = 0;
 
 	netdev->features = NETIF_F_LLTX | NETIF_F_SG | NETIF_F_FRAGLIST |
 			   NETIF_F_HIGHDMA | NETIF_F_HW_CSUM |
-- 
2.8.0
