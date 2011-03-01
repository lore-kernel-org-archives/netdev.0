From: Javier Martinez Canillas <martinez.javier@gmail.com>
Subject: [PATCH 5/5] tg3: Fix inline keyword usage
Date: Tue,  1 Mar 2011 18:04:29 +0100
Message-ID: <1298999069-12740-5-git-send-email-martinez.javier@gmail.com>
References: <1298999069-12740-1-git-send-email-martinez.javier@gmail.com>
Cc: Michael Chan <mchan@broadcom.com>,
	Grant Likely <grant.likely@secretlab.ca>,
	netdev@vger.kernel.org, kernelnewbies@kernelnewbies.org,
	Javier Martinez Canillas <martinez.javier@gmail.com>
To: Matt Carlson <mcarlson@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ew0-f46.google.com ([209.85.215.46]:42940 "EHLO
	mail-ew0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757019Ab1CARE3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Mar 2011 12:04:29 -0500
Received: by mail-ew0-f46.google.com with SMTP id 6so1731344ewy.19
        for <netdev@vger.kernel.org>; Tue, 01 Mar 2011 09:04:28 -0800 (PST)
In-Reply-To: <1298999069-12740-1-git-send-email-martinez.javier@gmail.com>
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

