From: Baole Ni <baolex.ni@intel.com>
Subject: [PATCH 0768/1285] Replace numeric parameter like 0444 with macro
Date: Tue,  2 Aug 2016 19:44:28 +0800
Message-ID: <20160802114428.860-1-baolex.ni@intel.com>
Cc: wcn36xx@lists.infradead.org, linux-wireless@vger.kernel.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	chuansheng.liu@intel.com, baolex.ni@intel.com,
	daniel@iogearbox.net, pabeni@redhat.com
To: k.eugene.e@gmail.com, kvalo@codeaurora.org,
	bkenward@solarflare.com, linux-driver@qlogic.com,
	computersforpeace@gmail.com, m.chehab@samsung.com,
	pawel@osciak.com, m.szyprowski@samsung.com,
	kyungmin.park@samsung.com, k.kozlowski@samsung.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:12252 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S934725AbcHBMW1 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 2 Aug 2016 08:22:27 -0400
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
 drivers/net/wireless/ath/wcn36xx/main.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/wireless/ath/wcn36xx/main.c b/drivers/net/wireless/ath/wcn36xx/main.c
index a920d70..477f2b2 100644
--- a/drivers/net/wireless/ath/wcn36xx/main.c
+++ b/drivers/net/wireless/ath/wcn36xx/main.c
@@ -22,7 +22,7 @@
 #include "wcn36xx.h"
 
 unsigned int wcn36xx_dbg_mask;
-module_param_named(debug_mask, wcn36xx_dbg_mask, uint, 0644);
+module_param_named(debug_mask, wcn36xx_dbg_mask, uint, S_IRUSR | S_IWUSR | S_IRGRP | S_IROTH);
 MODULE_PARM_DESC(debug_mask, "Debugging mask");
 
 #define CHAN2G(_freq, _idx) { \
-- 
2.9.2
