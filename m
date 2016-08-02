From: Baole Ni <baolex.ni@intel.com>
Subject: [PATCH 0778/1285] Replace numeric parameter like 0444 with macro
Date: Tue,  2 Aug 2016 19:45:29 +0800
Message-ID: <20160802114529.1606-1-baolex.ni@intel.com>
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, chuansheng.liu@intel.com,
	baolex.ni@intel.com, lars@metafoo.de, johannes.berg@intel.com
To: j@w1.fi, kvalo@codeaurora.org, luciano.coelho@intel.com,
	linuxwifi@intel.com, m.chehab@samsung.com, pawel@osciak.com,
	m.szyprowski@samsung.com, kyungmin.park@samsung.com,
	k.kozlowski@samsung.com
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
 drivers/net/wireless/intersil/hostap/hostap_ap.c | 8 ++++----
 1 file changed, 4 insertions(+), 4 deletions(-)

diff --git a/drivers/net/wireless/intersil/hostap/hostap_ap.c b/drivers/net/wireless/intersil/hostap/hostap_ap.c
index c995ace..c0c9f13 100644
--- a/drivers/net/wireless/intersil/hostap/hostap_ap.c
+++ b/drivers/net/wireless/intersil/hostap/hostap_ap.c
@@ -32,22 +32,22 @@
 
 static int other_ap_policy[MAX_PARM_DEVICES] = { AP_OTHER_AP_SKIP_ALL,
 						 DEF_INTS };
-module_param_array(other_ap_policy, int, NULL, 0444);
+module_param_array(other_ap_policy, int, NULL, S_IRUSR | S_IRGRP | S_IROTH);
 MODULE_PARM_DESC(other_ap_policy, "Other AP beacon monitoring policy (0-3)");
 
 static int ap_max_inactivity[MAX_PARM_DEVICES] = { AP_MAX_INACTIVITY_SEC,
 						   DEF_INTS };
-module_param_array(ap_max_inactivity, int, NULL, 0444);
+module_param_array(ap_max_inactivity, int, NULL, S_IRUSR | S_IRGRP | S_IROTH);
 MODULE_PARM_DESC(ap_max_inactivity, "AP timeout (in seconds) for station "
 		 "inactivity");
 
 static int ap_bridge_packets[MAX_PARM_DEVICES] = { 1, DEF_INTS };
-module_param_array(ap_bridge_packets, int, NULL, 0444);
+module_param_array(ap_bridge_packets, int, NULL, S_IRUSR | S_IRGRP | S_IROTH);
 MODULE_PARM_DESC(ap_bridge_packets, "Bridge packets directly between "
 		 "stations");
 
 static int autom_ap_wds[MAX_PARM_DEVICES] = { 0, DEF_INTS };
-module_param_array(autom_ap_wds, int, NULL, 0444);
+module_param_array(autom_ap_wds, int, NULL, S_IRUSR | S_IRGRP | S_IROTH);
 MODULE_PARM_DESC(autom_ap_wds, "Add WDS connections to other APs "
 		 "automatically");
 
-- 
2.9.2
