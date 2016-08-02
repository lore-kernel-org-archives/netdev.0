From: Baole Ni <baolex.ni@intel.com>
Subject: [PATCH 0767/1285] Replace numeric parameter like 0444 with macro
Date: Tue,  2 Aug 2016 19:44:23 +0800
Message-ID: <20160802114423.794-1-baolex.ni@intel.com>
Cc: linux-wireless@vger.kernel.org, ath9k-devel@lists.ath9k.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	chuansheng.liu@intel.com, baolex.ni@intel.com,
	daniel@iogearbox.net, pabeni@redhat.com
To: ath9k-devel@qca.qualcomm.com, kvalo@codeaurora.org,
	bkenward@solarflare.com, linux-driver@qlogic.com,
	computersforpeace@gmail.com, m.chehab@samsung.com,
	pawel@osciak.com, m.szyprowski@samsung.com,
	kyungmin.park@samsung.com, k.kozlowski@samsung.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:43106 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S934707AbcHBMWX (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 2 Aug 2016 08:22:23 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I find that the developers often just specified the numeric value
when calling a macro which is defined with a parameter for access permission.
As we know, these numeric value for access permission have had the corresponding macro,
and that using macro can improve the robustness and readability of the code,
thus, I suggest replacing the numeric parameter with the macro.

Signed-off-by: Chuansheng Liu <chuansheng.liu@intel.com>
Signed-off-by: Baole Ni <baolex.ni@intel.com>
---
 drivers/net/wireless/ath/ath9k/init.c | 14 +++++++-------
 1 file changed, 7 insertions(+), 7 deletions(-)

diff --git a/drivers/net/wireless/ath/ath9k/init.c b/drivers/net/wireless/ath/ath9k/init.c
index 2ee8624..5196633 100644
--- a/drivers/net/wireless/ath/ath9k/init.c
+++ b/drivers/net/wireless/ath/ath9k/init.c
@@ -42,33 +42,33 @@ module_param_named(debug, ath9k_debug, uint, 0);
 MODULE_PARM_DESC(debug, "Debugging mask");
 
 int ath9k_modparam_nohwcrypt;
-module_param_named(nohwcrypt, ath9k_modparam_nohwcrypt, int, 0444);
+module_param_named(nohwcrypt, ath9k_modparam_nohwcrypt, int, S_IRUSR | S_IRGRP | S_IROTH);
 MODULE_PARM_DESC(nohwcrypt, "Disable hardware encryption");
 
 int ath9k_led_blink;
-module_param_named(blink, ath9k_led_blink, int, 0444);
+module_param_named(blink, ath9k_led_blink, int, S_IRUSR | S_IRGRP | S_IROTH);
 MODULE_PARM_DESC(blink, "Enable LED blink on activity");
 
 static int ath9k_led_active_high = -1;
-module_param_named(led_active_high, ath9k_led_active_high, int, 0444);
+module_param_named(led_active_high, ath9k_led_active_high, int, S_IRUSR | S_IRGRP | S_IROTH);
 MODULE_PARM_DESC(led_active_high, "Invert LED polarity");
 
 static int ath9k_btcoex_enable;
-module_param_named(btcoex_enable, ath9k_btcoex_enable, int, 0444);
+module_param_named(btcoex_enable, ath9k_btcoex_enable, int, S_IRUSR | S_IRGRP | S_IROTH);
 MODULE_PARM_DESC(btcoex_enable, "Enable wifi-BT coexistence");
 
 static int ath9k_bt_ant_diversity;
-module_param_named(bt_ant_diversity, ath9k_bt_ant_diversity, int, 0444);
+module_param_named(bt_ant_diversity, ath9k_bt_ant_diversity, int, S_IRUSR | S_IRGRP | S_IROTH);
 MODULE_PARM_DESC(bt_ant_diversity, "Enable WLAN/BT RX antenna diversity");
 
 static int ath9k_ps_enable;
-module_param_named(ps_enable, ath9k_ps_enable, int, 0444);
+module_param_named(ps_enable, ath9k_ps_enable, int, S_IRUSR | S_IRGRP | S_IROTH);
 MODULE_PARM_DESC(ps_enable, "Enable WLAN PowerSave");
 
 #ifdef CONFIG_ATH9K_CHANNEL_CONTEXT
 
 int ath9k_use_chanctx;
-module_param_named(use_chanctx, ath9k_use_chanctx, int, 0444);
+module_param_named(use_chanctx, ath9k_use_chanctx, int, S_IRUSR | S_IRGRP | S_IROTH);
 MODULE_PARM_DESC(use_chanctx, "Enable channel context for concurrency");
 
 #endif /* CONFIG_ATH9K_CHANNEL_CONTEXT */
-- 
2.9.2
