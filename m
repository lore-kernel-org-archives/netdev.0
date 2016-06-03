From: Guenter Roeck <linux@roeck-us.net>
Subject: [PATCH] libertas_tf: Drop unused variable and define
Date: Fri,  3 Jun 2016 13:48:55 -0700
Message-ID: <1464986935-23361-1-git-send-email-linux@roeck-us.net>
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, Guenter Roeck <linux@roeck-us.net>
To: Kalle Valo <kvalo@codeaurora.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

gcc-6 reports:

drivers/net/wireless/marvell/libertas_tf/main.c:30:19: error:
	'lbtf_driver_version' defined but not used

with -Werror=unused-const-variable=.

Reported-by: Fengguang Wu <fengguang.wu@intel.com> [0-day test robot]
Signed-off-by: Guenter Roeck <linux@roeck-us.net>
---
 drivers/net/wireless/marvell/libertas_tf/main.c | 7 -------
 1 file changed, 7 deletions(-)

diff --git a/drivers/net/wireless/marvell/libertas_tf/main.c b/drivers/net/wireless/marvell/libertas_tf/main.c
index 0bf8916a02cf..75bf0c8a2f6f 100644
--- a/drivers/net/wireless/marvell/libertas_tf/main.c
+++ b/drivers/net/wireless/marvell/libertas_tf/main.c
@@ -16,7 +16,6 @@
 #include <linux/module.h>
 #include "libertas_tf.h"
 
-#define DRIVER_RELEASE_VERSION "004.p0"
 /* thinfirm version: 5.132.X.pX */
 #define LBTF_FW_VER_MIN		0x05840300
 #define LBTF_FW_VER_MAX		0x0584ffff
@@ -27,12 +26,6 @@ unsigned int lbtf_debug;
 EXPORT_SYMBOL_GPL(lbtf_debug);
 module_param_named(libertas_tf_debug, lbtf_debug, int, 0644);
 
-static const char lbtf_driver_version[] = "THINFIRM-USB8388-" DRIVER_RELEASE_VERSION
-#ifdef DEBUG
-	"-dbg"
-#endif
-	"";
-
 struct workqueue_struct *lbtf_wq;
 
 static const struct ieee80211_channel lbtf_channels[] = {
-- 
2.5.0
