From: Annie Li <annie.li@oracle.com>
Subject: [PATCH 4/4] fix code indent issue in xen-netfront.
Date: Thu, 15 Nov 2012 15:05:33 +0800
Message-ID: <1352963133-657-1-git-send-email-annie.li@oracle.com>
References: <1352962987-541-1-git-send-email-annie.li@oracle.com>
Cc: annie.li@oracle.com
To: xen-devel@lists.xensource.com, netdev@vger.kernel.org,
	konrad.wilk@oracle.com, Ian.Campbell@citrix.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from userp1040.oracle.com ([156.151.31.81]:37253 "EHLO
	userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753895Ab2KOHGr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 Nov 2012 02:06:47 -0500
In-Reply-To: <1352962987-541-1-git-send-email-annie.li@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Annie Li <annie.li@oracle.com>
---
 drivers/net/xen-netfront.c |    6 +++---
 1 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/drivers/net/xen-netfront.c b/drivers/net/xen-netfront.c
index 17b81c0..66bb29f 100644
--- a/drivers/net/xen-netfront.c
+++ b/drivers/net/xen-netfront.c
@@ -202,7 +202,7 @@ static struct sk_buff *xennet_get_rx_skb(struct netfront_info *np,
 }
 
 static grant_ref_t xennet_get_rx_ref(struct netfront_info *np,
-					    RING_IDX ri)
+				     RING_IDX ri)
 {
 	int i = xennet_rxidx(ri);
 	grant_ref_t ref = np->grant_rx_ref[i];
@@ -1420,7 +1420,7 @@ static void xennet_uninit(struct net_device *dev)
 }
 
 static netdev_features_t xennet_fix_features(struct net_device *dev,
-	netdev_features_t features)
+					     netdev_features_t features)
 {
 	struct netfront_info *np = netdev_priv(dev);
 	int val;
@@ -1447,7 +1447,7 @@ static netdev_features_t xennet_fix_features(struct net_device *dev,
 }
 
 static int xennet_set_features(struct net_device *dev,
-	netdev_features_t features)
+			       netdev_features_t features)
 {
 	if (!(features & NETIF_F_SG) && dev->mtu > ETH_DATA_LEN) {
 		netdev_info(dev, "Reducing MTU because no SG offload");
-- 
1.7.3.4
