From: Baole Ni <baolex.ni@intel.com>
Subject: [PATCH 0761/1285] Replace numeric parameter like 0444 with macro
Date: Tue,  2 Aug 2016 19:43:42 +0800
Message-ID: <20160802114342.394-1-baolex.ni@intel.com>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	chuansheng.liu@intel.com, baolex.ni@intel.com, tgraf@suug.ch,
	hannes@stressinduktion.org, daniel@iogearbox.net, pabeni@redhat.com
To: inaky.perez-gonzalez@intel.com, linux-wimax@intel.com,
	bkenward@solarflare.com, linux-driver@qlogic.com,
	computersforpeace@gmail.com, m.chehab@samsung.com,
	pawel@osciak.com, m.szyprowski@samsung.com,
	kyungmin.park@samsung.com, k.kozlowski@samsung.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([134.134.136.65]:63323 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S934475AbcHBMWX (ORCPT <rfc822;netdev@vger.kernel.org>);
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
 drivers/net/wimax/i2400m/rx.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/wimax/i2400m/rx.c b/drivers/net/wimax/i2400m/rx.c
index 0b60295..29a2dbb 100644
--- a/drivers/net/wimax/i2400m/rx.c
+++ b/drivers/net/wimax/i2400m/rx.c
@@ -158,7 +158,7 @@
 #include "debug-levels.h"
 
 static int i2400m_rx_reorder_disabled;	/* 0 (rx reorder enabled) by default */
-module_param_named(rx_reorder_disabled, i2400m_rx_reorder_disabled, int, 0644);
+module_param_named(rx_reorder_disabled, i2400m_rx_reorder_disabled, int, S_IRUSR | S_IWUSR | S_IRGRP | S_IROTH);
 MODULE_PARM_DESC(rx_reorder_disabled,
 		 "If true, RX reordering will be disabled.");
 
-- 
2.9.2
