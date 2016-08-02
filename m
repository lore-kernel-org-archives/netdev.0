From: Baole Ni <baolex.ni@intel.com>
Subject: [PATCH 1140/1285] Replace numeric parameter like 0444 with macro
Date: Tue,  2 Aug 2016 20:19:51 +0800
Message-ID: <20160802121951.26116-1-baolex.ni@intel.com>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	chuansheng.liu@intel.com, baolex.ni@intel.com, arnd@arndb.de,
	aryabinin@virtuozzo.com
To: inaky.perez-gonzalez@intel.com, davem@davemloft.net,
	linux-wimax@intel.com, anna.schumaker@netapp.com,
	kadlec@blackhole.kfki.hu, m.szyprowski@samsung.com,
	kyungmin.park@samsung.com, k.kozlowski@samsung.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:33099 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S965855AbcHBM5d (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 2 Aug 2016 08:57:33 -0400
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
 net/wimax/stack.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/wimax/stack.c b/net/wimax/stack.c
index 3f816e2..084ce9a 100644
--- a/net/wimax/stack.c
+++ b/net/wimax/stack.c
@@ -64,7 +64,7 @@
 
 static char wimax_debug_params[128];
 module_param_string(debug, wimax_debug_params, sizeof(wimax_debug_params),
-		    0644);
+		    S_IRUSR | S_IWUSR | S_IRGRP | S_IROTH);
 MODULE_PARM_DESC(debug,
 		 "String of space-separated NAME:VALUE pairs, where NAMEs "
 		 "are the different debug submodules and VALUE are the "
-- 
2.9.2
