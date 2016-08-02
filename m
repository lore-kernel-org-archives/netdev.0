From: Baole Ni <baolex.ni@intel.com>
Subject: [PATCH 0765/1285] Replace numeric parameter like 0444 with macro
Date: Tue,  2 Aug 2016 19:44:07 +0800
Message-ID: <20160802114407.661-1-baolex.ni@intel.com>
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, chuansheng.liu@intel.com,
	baolex.ni@intel.com, daniel@iogearbox.net, pabeni@redhat.com
To: kvalo@qca.qualcomm.com, linux-wimax@intel.com,
	bkenward@solarflare.com, linux-driver@qlogic.com,
	computersforpeace@gmail.com, m.chehab@samsung.com,
	pawel@osciak.com, m.szyprowski@samsung.com,
	kyungmin.park@samsung.com, k.kozlowski@samsung.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:6235 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S934705AbcHBMWX (ORCPT <rfc822;netdev@vger.kernel.org>);
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
 drivers/net/wireless/ath/ath6kl/core.c | 18 +++++++++---------
 1 file changed, 9 insertions(+), 9 deletions(-)

diff --git a/drivers/net/wireless/ath/ath6kl/core.c b/drivers/net/wireless/ath/ath6kl/core.c
index ebb9f16..6b5b18b 100644
--- a/drivers/net/wireless/ath/ath6kl/core.c
+++ b/drivers/net/wireless/ath/ath6kl/core.c
@@ -37,15 +37,15 @@ static unsigned int testmode;
 static unsigned int recovery_enable;
 static unsigned int heart_beat_poll;
 
-module_param(debug_mask, uint, 0644);
-module_param(suspend_mode, uint, 0644);
-module_param(wow_mode, uint, 0644);
-module_param(uart_debug, uint, 0644);
-module_param(uart_rate, uint, 0644);
-module_param(ath6kl_p2p, uint, 0644);
-module_param(testmode, uint, 0644);
-module_param(recovery_enable, uint, 0644);
-module_param(heart_beat_poll, uint, 0644);
+module_param(debug_mask, uint, S_IRUSR | S_IWUSR | S_IRGRP | S_IROTH);
+module_param(suspend_mode, uint, S_IRUSR | S_IWUSR | S_IRGRP | S_IROTH);
+module_param(wow_mode, uint, S_IRUSR | S_IWUSR | S_IRGRP | S_IROTH);
+module_param(uart_debug, uint, S_IRUSR | S_IWUSR | S_IRGRP | S_IROTH);
+module_param(uart_rate, uint, S_IRUSR | S_IWUSR | S_IRGRP | S_IROTH);
+module_param(ath6kl_p2p, uint, S_IRUSR | S_IWUSR | S_IRGRP | S_IROTH);
+module_param(testmode, uint, S_IRUSR | S_IWUSR | S_IRGRP | S_IROTH);
+module_param(recovery_enable, uint, S_IRUSR | S_IWUSR | S_IRGRP | S_IROTH);
+module_param(heart_beat_poll, uint, S_IRUSR | S_IWUSR | S_IRGRP | S_IROTH);
 MODULE_PARM_DESC(recovery_enable, "Enable recovery from firmware error");
 MODULE_PARM_DESC(heart_beat_poll,
 		 "Enable fw error detection periodic polling in msecs - Also set recovery_enable for this to be effective");
-- 
2.9.2
