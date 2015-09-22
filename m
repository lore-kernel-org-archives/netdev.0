From: Michael Grzeschik <m.grzeschik@pengutronix.de>
Subject: [PATCH 24/33] arcnet: arcdevice.h: Add arcnet_readb and arcnet_writeb
Date: Tue, 22 Sep 2015 11:02:05 +0200
Message-ID: <1442912534-10821-25-git-send-email-m.grzeschik@pengutronix.de>
References: <1442912534-10821-1-git-send-email-m.grzeschik@pengutronix.de>
Cc: netdev@vger.kernel.org, joe@perches.com, kernel@pengutronix.de
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from metis.ext.pengutronix.de ([92.198.50.35]:49429 "EHLO
	metis.ext.pengutronix.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932657AbbIVJCm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Sep 2015 05:02:42 -0400
In-Reply-To: <1442912534-10821-1-git-send-email-m.grzeschik@pengutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Joe Perches <joe@perches.com>

Use the same indirection as the other arcnet_<I/O> macros.
Neither of these new macros add the BUS_ALIGN use for 8 bit devices
on 16 bit busses.

Signed-off-by: Joe Perches <joe@perches.com>
Signed-off-by: Michael Grzeschik <m.grzeschik@pengutronix.de>
---
 drivers/net/arcnet/arcdevice.h | 5 +++++
 1 file changed, 5 insertions(+)

diff --git a/drivers/net/arcnet/arcdevice.h b/drivers/net/arcnet/arcdevice.h
index 4afa32b..a05a77d 100644
--- a/drivers/net/arcnet/arcdevice.h
+++ b/drivers/net/arcnet/arcdevice.h
@@ -373,5 +373,10 @@ void arcnet_timeout(struct net_device *dev);
 #define arcnet_outsw(addr, offset, buffer, count)			\
 	outsw((addr) + BUS_ALIGN * (offset), buffer, count)
 
+#define arcnet_readb(addr, offset)					\
+	readb((addr) + (offset))
+#define arcnet_writeb(value, addr, offset)				\
+	writeb(value, (addr) + (offset))
+
 #endif				/* __KERNEL__ */
 #endif				/* _LINUX_ARCDEVICE_H */
-- 
2.5.1
