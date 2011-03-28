From: "G.Balaji" <balajig81@gmail.com>
Subject: [PATCH] drivers net: Fix declaration ordering in inline functions.
Date: Mon, 28 Mar 2011 08:45:19 +0530
Message-ID: <1301282119-2887-1-git-send-email-balajig81@gmail.com>
Cc: netdev@vger.kernel.org, "G.Balaji" <balajig81@gmail.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-iy0-f174.google.com ([209.85.210.174]:39312 "EHLO
	mail-iy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752569Ab1C1DPr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 27 Mar 2011 23:15:47 -0400
Received: by iyb14 with SMTP id 14so2652415iyb.19
        for <netdev@vger.kernel.org>; Sun, 27 Mar 2011 20:15:47 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The correct usage should be "static inline void" instead of "static void inline"

Signed-off-by: G.Balaji <balajig81@gmail.com>
---
 drivers/net/bnx2.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

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
-- 
1.7.4

