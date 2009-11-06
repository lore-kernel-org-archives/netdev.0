From: Dmitry Eremin-Solenikov <dbaryshkov@gmail.com>
Subject: [PATCH 11/17] fakehard: no need to export net_to_phy, make it static
Date: Fri,  6 Nov 2009 15:39:35 +0300
Message-ID: <1257511181-19403-12-git-send-email-dbaryshkov@gmail.com>
References: <1257511181-19403-1-git-send-email-dbaryshkov@gmail.com>
Cc: netdev@vger.kernel.org, Sergey Lapin <slapin@ossfans.org>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ew0-f207.google.com ([209.85.219.207]:58044 "EHLO
	mail-ew0-f207.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758148AbZKFMk4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 Nov 2009 07:40:56 -0500
Received: by mail-ew0-f207.google.com with SMTP id 3so975605ewy.37
        for <netdev@vger.kernel.org>; Fri, 06 Nov 2009 04:41:01 -0800 (PST)
In-Reply-To: <1257511181-19403-1-git-send-email-dbaryshkov@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Dmitry Eremin-Solenikov <dbaryshkov@gmail.com>
---
 drivers/ieee802154/fakehard.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/ieee802154/fakehard.c b/drivers/ieee802154/fakehard.c
index 77fbb51..ccf83eb 100644
--- a/drivers/ieee802154/fakehard.c
+++ b/drivers/ieee802154/fakehard.c
@@ -32,7 +32,7 @@
 #include <net/nl802154.h>
 #include <net/wpan-phy.h>
 
-struct wpan_phy *net_to_phy(struct net_device *dev)
+static struct wpan_phy *net_to_phy(struct net_device *dev)
 {
 	return container_of(dev->dev.parent, struct wpan_phy, dev);
 }
-- 
1.6.5

