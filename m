From: Michael Grzeschik <m.grzeschik@pengutronix.de>
Subject: [PATCH 29/33] arcnet: Remove unused arcnet_<I/O>w macros
Date: Tue, 22 Sep 2015 11:02:10 +0200
Message-ID: <1442912534-10821-30-git-send-email-m.grzeschik@pengutronix.de>
References: <1442912534-10821-1-git-send-email-m.grzeschik@pengutronix.de>
Cc: netdev@vger.kernel.org, joe@perches.com, kernel@pengutronix.de
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from metis.ext.pengutronix.de ([92.198.50.35]:46240 "EHLO
	metis.ext.pengutronix.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932689AbbIVJCm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Sep 2015 05:02:42 -0400
In-Reply-To: <1442912534-10821-1-git-send-email-m.grzeschik@pengutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Joe Perches <joe@perches.com>

The word length macros are unused.  Remove them.

Signed-off-by: Joe Perches <joe@perches.com>
Signed-off-by: Michael Grzeschik <m.grzeschik@pengutronix.de>
---
 drivers/net/arcnet/arcdevice.h | 10 ----------
 1 file changed, 10 deletions(-)

diff --git a/drivers/net/arcnet/arcdevice.h b/drivers/net/arcnet/arcdevice.h
index 2577485..4c1c44c 100644
--- a/drivers/net/arcnet/arcdevice.h
+++ b/drivers/net/arcnet/arcdevice.h
@@ -358,16 +358,6 @@ void arcnet_timeout(struct net_device *dev);
 #define arcnet_outsb(addr, offset, buffer, count)			\
 	outsb((addr) + BUS_ALIGN * (offset), buffer, count)
 
-#define arcnet_inw(addr, offset)					\
-	inw((addr) + BUS_ALIGN * (offset))
-#define arcnet_outw(value, addr, offset)				\
-	outw(value, (addr) + BUS_ALIGN * (offset))
-
-#define arcnet_insw(addr, offset, buffer, count)			\
-	insw((addr) + BUS_ALIGN * (offset), buffer, count)
-#define arcnet_outsw(addr, offset, buffer, count)			\
-	outsw((addr) + BUS_ALIGN * (offset), buffer, count)
-
 #define arcnet_readb(addr, offset)					\
 	readb((addr) + (offset))
 #define arcnet_writeb(value, addr, offset)				\
-- 
2.5.1
