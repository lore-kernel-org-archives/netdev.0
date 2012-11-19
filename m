From: Sachin Kamat <sachin.kamat-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>
Subject: [PATCH 1/1] iwlwifi: Remove duplicate inclusion of iwl-trans.h in pcie/drv.c
Date: Mon, 19 Nov 2012 17:15:40 +0530
Message-ID: <1353325540-9338-1-git-send-email-sachin.kamat@linaro.org>
Cc: johannes.berg-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org, ilw-VuQAYsv1563Yd54FQh9/CA@public.gmane.org,
	wey-yi.w.guy-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org, sachin.kamat-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org, patches-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org
To: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

iwl-trans.h was included twice.

Signed-off-by: Sachin Kamat <sachin.kamat-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>
---
 drivers/net/wireless/iwlwifi/pcie/drv.c |    1 -
 1 files changed, 0 insertions(+), 1 deletions(-)

diff --git a/drivers/net/wireless/iwlwifi/pcie/drv.c b/drivers/net/wireless/iwlwifi/pcie/drv.c
index 2a46753..956fe6c 100644
--- a/drivers/net/wireless/iwlwifi/pcie/drv.c
+++ b/drivers/net/wireless/iwlwifi/pcie/drv.c
@@ -69,7 +69,6 @@
 
 #include "iwl-trans.h"
 #include "iwl-drv.h"
-#include "iwl-trans.h"
 
 #include "cfg.h"
 #include "internal.h"
-- 
1.7.4.1

--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
