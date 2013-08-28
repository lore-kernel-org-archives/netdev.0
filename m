From: Lutz Jaenicke <ljaenicke@innominate.com>
Subject: [PATCH] macvlan: fix typo in assignment
Date: Wed, 28 Aug 2013 13:34:31 +0200
Message-ID: <1377689671-28666-1-git-send-email-ljaenicke@innominate.com>
Cc: Lutz Jaenicke <ljaenicke@innominate.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from home.innominate.com ([77.245.32.75]:35728 "EHLO
	home.innominate.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753472Ab3H1Les (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 28 Aug 2013 07:34:48 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

commit 3b04ddde02cf1b6f14f2697da5c20eca5715017f
"[NET]: Move hardware header operations out of netdevice."
moved the handling into macvlan setup adding
  dev->header_ops         = &macvlan_hard_header_ops,
At the end of the line the ',' should have been a ';'

Signed-off-by: Lutz Jaenicke <ljaenicke@innominate.com>
---
 drivers/net/macvlan.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/macvlan.c b/drivers/net/macvlan.c
index 16b43bf..4e2698d 100644
--- a/drivers/net/macvlan.c
+++ b/drivers/net/macvlan.c
@@ -683,7 +683,7 @@ void macvlan_common_setup(struct net_device *dev)
 	dev->priv_flags	       |= IFF_UNICAST_FLT;
 	dev->netdev_ops		= &macvlan_netdev_ops;
 	dev->destructor		= free_netdev;
-	dev->header_ops		= &macvlan_hard_header_ops,
+	dev->header_ops		= &macvlan_hard_header_ops;
 	dev->ethtool_ops	= &macvlan_ethtool_ops;
 }
 EXPORT_SYMBOL_GPL(macvlan_common_setup);
-- 
1.7.10.4
