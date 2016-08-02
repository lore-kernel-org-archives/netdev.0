From: Baole Ni <baolex.ni@intel.com>
Subject: [PATCH 0796/1285] Replace numeric parameter like 0444 with macro
Date: Tue,  2 Aug 2016 19:47:17 +0800
Message-ID: <20160802114717.2897-1-baolex.ni@intel.com>
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, chuansheng.liu@intel.com,
	baolex.ni@intel.com
To: Larry.Finger@lwfinger.net, chaoming_li@realsil.com.cn,
	kvalo@codeaurora.org, linuxwifi@intel.com, m.chehab@samsung.com,
	pawel@osciak.com, m.szyprowski@samsung.com,
	kyungmin.park@samsung.com, k.kozlowski@samsung.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([134.134.136.65]:16843 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S934939AbcHBM3J (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 2 Aug 2016 08:29:09 -0400
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
 drivers/net/wireless/realtek/rtlwifi/rtl8192de/sw.c | 10 +++++-----
 1 file changed, 5 insertions(+), 5 deletions(-)

diff --git a/drivers/net/wireless/realtek/rtlwifi/rtl8192de/sw.c b/drivers/net/wireless/realtek/rtlwifi/rtl8192de/sw.c
index c6e09a1..162f60a 100644
--- a/drivers/net/wireless/realtek/rtlwifi/rtl8192de/sw.c
+++ b/drivers/net/wireless/realtek/rtlwifi/rtl8192de/sw.c
@@ -369,11 +369,11 @@ MODULE_LICENSE("GPL");
 MODULE_DESCRIPTION("Realtek 8192DE 802.11n Dual Mac PCI wireless");
 MODULE_FIRMWARE("rtlwifi/rtl8192defw.bin");
 
-module_param_named(swenc, rtl92de_mod_params.sw_crypto, bool, 0444);
-module_param_named(debug, rtl92de_mod_params.debug, int, 0444);
-module_param_named(ips, rtl92de_mod_params.inactiveps, bool, 0444);
-module_param_named(swlps, rtl92de_mod_params.swctrl_lps, bool, 0444);
-module_param_named(fwlps, rtl92de_mod_params.fwctrl_lps, bool, 0444);
+module_param_named(swenc, rtl92de_mod_params.sw_crypto, bool, S_IRUSR | S_IRGRP | S_IROTH);
+module_param_named(debug, rtl92de_mod_params.debug, int, S_IRUSR | S_IRGRP | S_IROTH);
+module_param_named(ips, rtl92de_mod_params.inactiveps, bool, S_IRUSR | S_IRGRP | S_IROTH);
+module_param_named(swlps, rtl92de_mod_params.swctrl_lps, bool, S_IRUSR | S_IRGRP | S_IROTH);
+module_param_named(fwlps, rtl92de_mod_params.fwctrl_lps, bool, S_IRUSR | S_IRGRP | S_IROTH);
 MODULE_PARM_DESC(swenc, "Set to 1 for software crypto (default 0)\n");
 MODULE_PARM_DESC(ips, "Set to 0 to not use link power save (default 1)\n");
 MODULE_PARM_DESC(swlps, "Set to 1 to use SW control power save (default 1)\n");
-- 
2.9.2
