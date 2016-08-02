From: Baole Ni <baolex.ni@intel.com>
Subject: [PATCH 0780/1285] Replace numeric parameter like 0444 with macro
Date: Tue,  2 Aug 2016 19:45:39 +0800
Message-ID: <20160802114539.1742-1-baolex.ni@intel.com>
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, chuansheng.liu@intel.com,
	baolex.ni@intel.com, lars@metafoo.de, johannes.berg@intel.com
To: j@w1.fi, kvalo@codeaurora.org, luciano.coelho@intel.com,
	linuxwifi@intel.com, m.chehab@samsung.com, pawel@osciak.com,
	m.szyprowski@samsung.com, kyungmin.park@samsung.com,
	k.kozlowski@samsung.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([192.55.52.115]:54423 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S934696AbcHBM0j (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 2 Aug 2016 08:26:39 -0400
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
 drivers/net/wireless/intersil/hostap/hostap_hw.c | 14 +++++++-------
 1 file changed, 7 insertions(+), 7 deletions(-)

diff --git a/drivers/net/wireless/intersil/hostap/hostap_hw.c b/drivers/net/wireless/intersil/hostap/hostap_hw.c
index a8a9bd8..9d7230e 100644
--- a/drivers/net/wireless/intersil/hostap/hostap_hw.c
+++ b/drivers/net/wireless/intersil/hostap/hostap_hw.c
@@ -58,31 +58,31 @@
 /* #define final_version */
 
 static int mtu = 1500;
-module_param(mtu, int, 0444);
+module_param(mtu, int, S_IRUSR | S_IRGRP | S_IROTH);
 MODULE_PARM_DESC(mtu, "Maximum transfer unit");
 
 static int channel[MAX_PARM_DEVICES] = { 3, DEF_INTS };
-module_param_array(channel, int, NULL, 0444);
+module_param_array(channel, int, NULL, S_IRUSR | S_IRGRP | S_IROTH);
 MODULE_PARM_DESC(channel, "Initial channel");
 
 static char essid[33] = "test";
-module_param_string(essid, essid, sizeof(essid), 0444);
+module_param_string(essid, essid, sizeof(essid), S_IRUSR | S_IRGRP | S_IROTH);
 MODULE_PARM_DESC(essid, "Host AP's ESSID");
 
 static int iw_mode[MAX_PARM_DEVICES] = { IW_MODE_MASTER, DEF_INTS };
-module_param_array(iw_mode, int, NULL, 0444);
+module_param_array(iw_mode, int, NULL, S_IRUSR | S_IRGRP | S_IROTH);
 MODULE_PARM_DESC(iw_mode, "Initial operation mode");
 
 static int beacon_int[MAX_PARM_DEVICES] = { 100, DEF_INTS };
-module_param_array(beacon_int, int, NULL, 0444);
+module_param_array(beacon_int, int, NULL, S_IRUSR | S_IRGRP | S_IROTH);
 MODULE_PARM_DESC(beacon_int, "Beacon interval (1 = 1024 usec)");
 
 static int dtim_period[MAX_PARM_DEVICES] = { 1, DEF_INTS };
-module_param_array(dtim_period, int, NULL, 0444);
+module_param_array(dtim_period, int, NULL, S_IRUSR | S_IRGRP | S_IROTH);
 MODULE_PARM_DESC(dtim_period, "DTIM period");
 
 static char dev_template[16] = "wlan%d";
-module_param_string(dev_template, dev_template, sizeof(dev_template), 0444);
+module_param_string(dev_template, dev_template, sizeof(dev_template), S_IRUSR | S_IRGRP | S_IROTH);
 MODULE_PARM_DESC(dev_template, "Prefix for network device name (default: "
 		 "wlan%d)");
 
-- 
2.9.2
