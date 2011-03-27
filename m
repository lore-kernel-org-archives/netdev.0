From: "G.Balaji" <balajig81@gmail.com>
Subject: [PATCH] Change in inline keyword usage.
Date: Sun, 27 Mar 2011 14:18:30 +0530
Message-ID: <1301215710-8112-1-git-send-email-balajig81@gmail.com>
Cc: netdev@vger.kernel.org, "G.Balaji" <balajig81@gmail.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-iw0-f174.google.com ([209.85.214.174]:42742 "EHLO
	mail-iw0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752639Ab1C0ItE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 27 Mar 2011 04:49:04 -0400
Received: by iwn34 with SMTP id 34so2573939iwn.19
        for <netdev@vger.kernel.org>; Sun, 27 Mar 2011 01:49:03 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Signed-off-by: G.Balaji <balajig81@gmail.com>
---
 drivers/net/bnx2.c |    2 +-
 drivers/net/tg3.c  |    2 +-
 2 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/bnx2.c b/drivers/net/bnx2.c
index d1865cc..8e6d618 100644
--- a/drivers/net/bnx2.c
+++ b/drivers/net/bnx2.c
@@ -8317,7 +8317,7 @@ static const struct net_device_ops bnx2_netdev_ops = {
 #endif
 };
 
-static void inline vlan_features_add(struct net_device *dev, u32 flags)
+static inline void vlan_features_add(struct net_device *dev, u32 flags)
 {
 	dev->vlan_features |= flags;
 }
diff --git a/drivers/net/tg3.c b/drivers/net/tg3.c
index ebec888..bddcf25 100644
--- a/drivers/net/tg3.c
+++ b/drivers/net/tg3.c
@@ -13118,7 +13118,7 @@ done:
 
 static struct pci_dev * __devinit tg3_find_peer(struct tg3 *);
 
-static void inline vlan_features_add(struct net_device *dev, unsigned long flags)
+static inline void vlan_features_add(struct net_device *dev, unsigned long flags)
 {
 	dev->vlan_features |= flags;
 }
-- 
1.7.4

