From: Baole Ni <baolex.ni@intel.com>
Subject: [PATCH 0795/1285] Replace numeric parameter like 0444 with macro
Date: Tue,  2 Aug 2016 19:47:10 +0800
Message-ID: <20160802114710.2825-1-baolex.ni@intel.com>
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, adrien+dev@schischi.me,
	chuansheng.liu@intel.com, baolex.ni@intel.com
To: Larry.Finger@lwfinger.net, chaoming_li@realsil.com.cn,
	kvalo@codeaurora.org, linuxwifi@intel.com, m.chehab@samsung.com,
	pawel@osciak.com, m.szyprowski@samsung.com,
	kyungmin.park@samsung.com, k.kozlowski@samsung.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([134.134.136.65]:41396 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S934875AbcHBM3B (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 2 Aug 2016 08:29:01 -0400
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
 drivers/net/wireless/realtek/rtlwifi/rtl8192cu/sw.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/wireless/realtek/rtlwifi/rtl8192cu/sw.c b/drivers/net/wireless/realtek/rtlwifi/rtl8192cu/sw.c
index 7c6f7f0..d704e18 100644
--- a/drivers/net/wireless/realtek/rtlwifi/rtl8192cu/sw.c
+++ b/drivers/net/wireless/realtek/rtlwifi/rtl8192cu/sw.c
@@ -164,8 +164,8 @@ static struct rtl_mod_params rtl92cu_mod_params = {
 	.debug = DBG_EMERG,
 };
 
-module_param_named(swenc, rtl92cu_mod_params.sw_crypto, bool, 0444);
-module_param_named(debug, rtl92cu_mod_params.debug, int, 0444);
+module_param_named(swenc, rtl92cu_mod_params.sw_crypto, bool, S_IRUSR | S_IRGRP | S_IROTH);
+module_param_named(debug, rtl92cu_mod_params.debug, int, S_IRUSR | S_IRGRP | S_IROTH);
 MODULE_PARM_DESC(swenc, "Set to 1 for software crypto (default 0)\n");
 MODULE_PARM_DESC(debug, "Set debug level (0-5) (default 0)");
 
-- 
2.9.2
