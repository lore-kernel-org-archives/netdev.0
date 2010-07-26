From: Joe Perches <joe@perches.com>
Subject: [PATCH net-next 3/4] drivers/net/wireless/at76c50x-usb.c: Neaten macros
Date: Mon, 26 Jul 2010 14:39:59 -0700
Message-ID: <4d2eea02d3f58e2291205199788f4a0dedba5e64.1280177971.git.joe@perches.com>
References: <cover.1280177971.git.joe@perches.com>
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: "John W. Linville" <linville@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.perches.com ([173.55.12.10]:2098 "EHLO mail.perches.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753042Ab0GZVkD (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 26 Jul 2010 17:40:03 -0400
In-Reply-To: <cover.1280177971.git.joe@perches.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Joe Perches <joe@perches.com>
---
 drivers/net/wireless/at76c50x-usb.c |   27 ++++++++++++---------------
 1 files changed, 12 insertions(+), 15 deletions(-)

diff --git a/drivers/net/wireless/at76c50x-usb.c b/drivers/net/wireless/at76c50x-usb.c
index 9b0f055..d5140a8 100644
--- a/drivers/net/wireless/at76c50x-usb.c
+++ b/drivers/net/wireless/at76c50x-usb.c
@@ -89,22 +89,19 @@
 #define DBG_DEFAULTS		0
 
 /* Use our own dbg macro */
-#define at76_dbg(bits, format, arg...) \
-	do { \
-		if (at76_debug & (bits))				 \
-			printk(KERN_DEBUG DRIVER_NAME ": " format "\n" , \
-			       ## arg);					 \
-	} while (0)
-
-#define at76_dbg_dump(bits, buf, len, format, arg...)	\
-	do { \
-		if (at76_debug & (bits)) { \
-			printk(KERN_DEBUG DRIVER_NAME ": " format "\n" , \
-			       ## arg);					 \
-			print_hex_dump_bytes("", DUMP_PREFIX_OFFSET,     \
-					     buf, len);			 \
-		}							 \
-	} while (0)
+#define at76_dbg(bits, format, arg...)					\
+do {									\
+	if (at76_debug & (bits))					\
+		printk(KERN_DEBUG DRIVER_NAME ": " format "\n", ##arg);	\
+} while (0)
+
+#define at76_dbg_dump(bits, buf, len, format, arg...)			\
+do {									\
+	if (at76_debug & (bits)) {					\
+		printk(KERN_DEBUG DRIVER_NAME ": " format "\n", ##arg);	\
+		print_hex_dump_bytes("", DUMP_PREFIX_OFFSET, buf, len);	\
+	}								\
+} while (0)
 
 static uint at76_debug = DBG_DEFAULTS;
 
-- 
1.7.1

