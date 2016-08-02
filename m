From: Baole Ni <baolex.ni@intel.com>
Subject: [PATCH 0746/1285] Replace numeric parameter like 0444 with macro
Date: Tue,  2 Aug 2016 19:42:14 +0800
Message-ID: <20160802114214.31794-1-baolex.ni@intel.com>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	davem@davemloft.net, jesse@kernel.org, linville@tuxdriver.com,
	pshelar@nicira.com, jbenc@redhat.com, daniel@iogearbox.net,
	hannes@stressinduktion.org, tom@herbertland.com,
	aduyck@mirantis.com, chuansheng.liu@intel.com, baolex.ni@intel.com
To: michal.simek@xilinx.com, soren.brinkmann@xilinx.com,
	bkenward@solarflare.com, linux-driver@qlogic.com,
	computersforpeace@gmail.com, m.chehab@samsung.com,
	pawel@osciak.com, m.szyprowski@samsung.com,
	kyungmin.park@samsung.com, k.kozlowski@samsung.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([192.55.52.115]:9329 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S934502AbcHBMT6 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 2 Aug 2016 08:19:58 -0400
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
 drivers/net/geneve.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/geneve.c b/drivers/net/geneve.c
index cadefe4..2ddaa09 100644
--- a/drivers/net/geneve.c
+++ b/drivers/net/geneve.c
@@ -32,7 +32,7 @@
 #define VNI_HASH_SIZE		(1<<VNI_HASH_BITS)
 
 static bool log_ecn_error = true;
-module_param(log_ecn_error, bool, 0644);
+module_param(log_ecn_error, bool, S_IRUSR | S_IWUSR | S_IRGRP | S_IROTH);
 MODULE_PARM_DESC(log_ecn_error, "Log packets received with corrupted ECN");
 
 #define GENEVE_VER 0
-- 
2.9.2
