From: Sachin Kamat <sachin.kamat-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>
Subject: [PATCH 1/1] net: wireless: wl3501_cs: Remove duplicate include
Date: Mon, 17 Feb 2014 15:25:01 +0530
Message-ID: <1392630901-16232-1-git-send-email-sachin.kamat@linaro.org>
Cc: linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org, acme-f8uhVLnGfZaxAyOMLChx1axOck334EZe@public.gmane.org,
	sachin.kamat-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org
To: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

linux/etherdevice.h was included twice.

Signed-off-by: Sachin Kamat <sachin.kamat-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>
---
 drivers/net/wireless/wl3501_cs.c |    1 -
 1 file changed, 1 deletion(-)

diff --git a/drivers/net/wireless/wl3501_cs.c b/drivers/net/wireless/wl3501_cs.c
index d24d4a958c67..66bca677c4fa 100644
--- a/drivers/net/wireless/wl3501_cs.c
+++ b/drivers/net/wireless/wl3501_cs.c
@@ -43,7 +43,6 @@
 #include <linux/string.h>
 #include <linux/wireless.h>
 #include <linux/ieee80211.h>
-#include <linux/etherdevice.h>
 
 #include <net/iw_handler.h>
 
-- 
1.7.9.5

--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
