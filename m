From: Michael Grzeschik <m.grzeschik@pengutronix.de>
Subject: [PATCH 16/33] arcnet: Convert arcnet_dump_skb macro to static inline
Date: Tue, 22 Sep 2015 11:01:57 +0200
Message-ID: <1442912534-10821-17-git-send-email-m.grzeschik@pengutronix.de>
References: <1442912534-10821-1-git-send-email-m.grzeschik@pengutronix.de>
Cc: netdev@vger.kernel.org, joe@perches.com, kernel@pengutronix.de
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from metis.ext.pengutronix.de ([92.198.50.35]:39162 "EHLO
	metis.ext.pengutronix.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932621AbbIVJCm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Sep 2015 05:02:42 -0400
In-Reply-To: <1442912534-10821-1-git-send-email-m.grzeschik@pengutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Joe Perches <joe@perches.com>

Make sure the arguments are tested appropriately when not using
this function.

Signed-off-by: Joe Perches <joe@perches.com>
Signed-off-by: Michael Grzeschik <m.grzeschik@pengutronix.de>
---
 include/linux/arcdevice.h | 5 ++++-
 1 file changed, 4 insertions(+), 1 deletion(-)

diff --git a/include/linux/arcdevice.h b/include/linux/arcdevice.h
index a678027..1d8e36e 100644
--- a/include/linux/arcdevice.h
+++ b/include/linux/arcdevice.h
@@ -326,7 +326,10 @@ struct arcnet_local {
 #if ARCNET_DEBUG_MAX & D_SKB
 void arcnet_dump_skb(struct net_device *dev, struct sk_buff *skb, char *desc);
 #else
-#define arcnet_dump_skb(dev, skb, desc) ;
+static inline
+void arcnet_dump_skb(struct net_device *dev, struct sk_buff *skb, char *desc)
+{
+}
 #endif
 
 void arcnet_unregister_proto(struct ArcProto *proto);
-- 
2.5.1
