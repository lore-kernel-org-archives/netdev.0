From: Baole Ni <baolex.ni@intel.com>
Subject: [PATCH 0715/1285] Replace numeric parameter like 0444 with macro
Date: Tue,  2 Aug 2016 19:39:16 +0800
Message-ID: <20160802113916.29727-1-baolex.ni@intel.com>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	chuansheng.liu@intel.com, baolex.ni@intel.com, mugunthanvnm@ti.com,
	felipe.balbi@linux.intel.com, fw@strlen.de
To: leedom@chelsio.com, rric@kernel.org,
	felix.manlunas@caviumnetworks.com,
	raghu.vatsavayi@caviumnetworks.com, computersforpeace@gmail.com,
	m.chehab@samsung.com, pawel@osciak.com, m.szyprowski@samsung.com,
	kyungmin.park@samsung.com, k.kozlowski@samsung.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga04.intel.com ([192.55.52.120]:22496 "EHLO mga04.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S934290AbcHBMRg (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 2 Aug 2016 08:17:36 -0400
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
 drivers/net/ethernet/chelsio/cxgb4vf/cxgb4vf_main.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/chelsio/cxgb4vf/cxgb4vf_main.c b/drivers/net/ethernet/chelsio/cxgb4vf/cxgb4vf_main.c
index 04fc6f6..dc4fe21 100644
--- a/drivers/net/ethernet/chelsio/cxgb4vf/cxgb4vf_main.c
+++ b/drivers/net/ethernet/chelsio/cxgb4vf/cxgb4vf_main.c
@@ -72,7 +72,7 @@
 
 static int dflt_msg_enable = DFLT_MSG_ENABLE;
 
-module_param(dflt_msg_enable, int, 0644);
+module_param(dflt_msg_enable, int, S_IRUSR | S_IWUSR | S_IRGRP | S_IROTH);
 MODULE_PARM_DESC(dflt_msg_enable,
 		 "default adapter ethtool message level bitmap, "
 		 "deprecated parameter");
@@ -95,7 +95,7 @@ MODULE_PARM_DESC(dflt_msg_enable,
 
 static int msi = MSI_DEFAULT;
 
-module_param(msi, int, 0644);
+module_param(msi, int, S_IRUSR | S_IWUSR | S_IRGRP | S_IROTH);
 MODULE_PARM_DESC(msi, "whether to use MSI-X or MSI");
 
 /*
-- 
2.9.2
