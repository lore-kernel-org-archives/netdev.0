From: Baole Ni <baolex.ni@intel.com>
Subject: [PATCH 0760/1285] Replace numeric parameter like 0444 with macro
Date: Tue,  2 Aug 2016 19:43:37 +0800
Message-ID: <20160802114337.314-1-baolex.ni@intel.com>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	chuansheng.liu@intel.com, baolex.ni@intel.com, tgraf@suug.ch,
	hannes@stressinduktion.org, daniel@iogearbox.net, pabeni@redhat.com
To: inaky.perez-gonzalez@intel.com, linux-wimax@intel.com,
	bkenward@solarflare.com, linux-driver@qlogic.com,
	computersforpeace@gmail.com, m.chehab@samsung.com,
	pawel@osciak.com, m.szyprowski@samsung.com,
	kyungmin.park@samsung.com, k.kozlowski@samsung.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:28358 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S934787AbcHBMYu (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 2 Aug 2016 08:24:50 -0400
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
 drivers/net/wimax/i2400m/driver.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/wimax/i2400m/driver.c b/drivers/net/wimax/i2400m/driver.c
index 9c78090..42eb711 100644
--- a/drivers/net/wimax/i2400m/driver.c
+++ b/drivers/net/wimax/i2400m/driver.c
@@ -77,7 +77,7 @@
 
 static char i2400m_debug_params[128];
 module_param_string(debug, i2400m_debug_params, sizeof(i2400m_debug_params),
-		    0644);
+		    S_IRUSR | S_IWUSR | S_IRGRP | S_IROTH);
 MODULE_PARM_DESC(debug,
 		 "String of space-separated NAME:VALUE pairs, where NAMEs "
 		 "are the different debug submodules and VALUE are the "
@@ -85,7 +85,7 @@ MODULE_PARM_DESC(debug,
 
 static char i2400m_barkers_params[128];
 module_param_string(barkers, i2400m_barkers_params,
-		    sizeof(i2400m_barkers_params), 0644);
+		    sizeof(i2400m_barkers_params), S_IRUSR | S_IWUSR | S_IRGRP | S_IROTH);
 MODULE_PARM_DESC(barkers,
 		 "String of comma-separated 32-bit values; each is "
 		 "recognized as the value the device sends as a reboot "
-- 
2.9.2
