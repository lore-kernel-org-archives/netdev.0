From: Baole Ni <baolex.ni@intel.com>
Subject: [PATCH 0766/1285] Replace numeric parameter like 0444 with macro
Date: Tue,  2 Aug 2016 19:44:12 +0800
Message-ID: <20160802114412.727-1-baolex.ni@intel.com>
Cc: linux-wireless@vger.kernel.org, ath9k-devel@lists.ath9k.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	chuansheng.liu@intel.com, baolex.ni@intel.com,
	daniel@iogearbox.net, pabeni@redhat.com
To: ath9k-devel@qca.qualcomm.com, kvalo@codeaurora.org,
	bkenward@solarflare.com, linux-driver@qlogic.com,
	computersforpeace@gmail.com, m.chehab@samsung.com,
	pawel@osciak.com, m.szyprowski@samsung.com,
	kyungmin.park@samsung.com, k.kozlowski@samsung.com
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

I find that the developers often just specified the numeric value
when calling a macro which is defined with a parameter for access permission.
As we know, these numeric value for access permission have had the corresponding macro,
and that using macro can improve the robustness and readability of the code,
thus, I suggest replacing the numeric parameter with the macro.

Signed-off-by: Chuansheng Liu <chuansheng.liu@intel.com>
Signed-off-by: Baole Ni <baolex.ni@intel.com>
---
 drivers/net/wireless/ath/ath9k/htc_drv_init.c | 10 +++++-----
 1 file changed, 5 insertions(+), 5 deletions(-)

diff --git a/drivers/net/wireless/ath/ath9k/htc_drv_init.c b/drivers/net/wireless/ath/ath9k/htc_drv_init.c
index c148c6c..3119d4f 100644
--- a/drivers/net/wireless/ath/ath9k/htc_drv_init.c
+++ b/drivers/net/wireless/ath/ath9k/htc_drv_init.c
@@ -27,24 +27,24 @@ module_param_named(debug, ath9k_debug, uint, 0);
 MODULE_PARM_DESC(debug, "Debugging mask");
 
 int htc_modparam_nohwcrypt;
-module_param_named(nohwcrypt, htc_modparam_nohwcrypt, int, 0444);
+module_param_named(nohwcrypt, htc_modparam_nohwcrypt, int, S_IRUSR | S_IRGRP | S_IROTH);
 MODULE_PARM_DESC(nohwcrypt, "Disable hardware encryption");
 
 static int ath9k_htc_btcoex_enable;
-module_param_named(btcoex_enable, ath9k_htc_btcoex_enable, int, 0444);
+module_param_named(btcoex_enable, ath9k_htc_btcoex_enable, int, S_IRUSR | S_IRGRP | S_IROTH);
 MODULE_PARM_DESC(btcoex_enable, "Enable wifi-BT coexistence");
 
 static int ath9k_ps_enable;
-module_param_named(ps_enable, ath9k_ps_enable, int, 0444);
+module_param_named(ps_enable, ath9k_ps_enable, int, S_IRUSR | S_IRGRP | S_IROTH);
 MODULE_PARM_DESC(ps_enable, "Enable WLAN PowerSave");
 
 int htc_use_dev_fw = 0;
-module_param_named(use_dev_fw, htc_use_dev_fw, int, 0444);
+module_param_named(use_dev_fw, htc_use_dev_fw, int, S_IRUSR | S_IRGRP | S_IROTH);
 MODULE_PARM_DESC(use_dev_fw, "Use development FW version");
 
 #ifdef CONFIG_MAC80211_LEDS
 int ath9k_htc_led_blink = 1;
-module_param_named(blink, ath9k_htc_led_blink, int, 0444);
+module_param_named(blink, ath9k_htc_led_blink, int, S_IRUSR | S_IRGRP | S_IROTH);
 MODULE_PARM_DESC(blink, "Enable LED blink on activity");
 
 static const struct ieee80211_tpt_blink ath9k_htc_tpt_blink[] = {
-- 
2.9.2
