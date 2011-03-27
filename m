From: Javier Martinez Canillas <martinez.javier@gmail.com>
Subject: [PATCH 3/3] tg3: Fix inline keyword usage
Date: Sun, 27 Mar 2011 04:42:33 +0200
Message-ID: <1301193753-10045-3-git-send-email-martinez.javier@gmail.com>
References: <1301193753-10045-1-git-send-email-martinez.javier@gmail.com>
Cc: Michael Chan <mchan@broadcom.com>, netdev@vger.kernel.org,
	kernel-janitors@vger.kernel.org,
	Javier Martinez Canillas <martinez.javier@gmail.com>
To: Matt Carlson <mcarlson@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:57783 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752580Ab1C0CmN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 26 Mar 2011 22:42:13 -0400
In-Reply-To: <1301193753-10045-1-git-send-email-martinez.javier@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The correct usage is "static inline void" not "static void inline".

Signed-off-by: Javier Martinez Canillas <martinez.javier@gmail.com>
---
 drivers/net/tg3.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/tg3.c b/drivers/net/tg3.c
index 58c6049..d7e564d 100644
--- a/drivers/net/tg3.c
+++ b/drivers/net/tg3.c
@@ -13061,7 +13061,7 @@ done:
 
 static struct pci_dev * __devinit tg3_find_peer(struct tg3 *);
 
-static void inline vlan_features_add(struct net_device *dev, unsigned long flags)
+static inline void vlan_features_add(struct net_device *dev, unsigned long flags)
 {
 	dev->vlan_features |= flags;
 }
-- 
1.7.2.3

