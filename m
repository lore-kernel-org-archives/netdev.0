From: Baole Ni <baolex.ni@intel.com>
Subject: [PATCH 0713/1285] Replace numeric parameter like 0444 with macro
Date: Tue,  2 Aug 2016 19:39:06 +0800
Message-ID: <20160802113906.29595-1-baolex.ni@intel.com>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	chuansheng.liu@intel.com, baolex.ni@intel.com, mugunthanvnm@ti.com,
	felipe.balbi@linux.intel.com, fw@strlen.de
To: santosh@chelsio.com, rric@kernel.org,
	felix.manlunas@caviumnetworks.com,
	raghu.vatsavayi@caviumnetworks.com, computersforpeace@gmail.com,
	m.chehab@samsung.com, pawel@osciak.com, m.szyprowski@samsung.com,
	kyungmin.park@samsung.com, k.kozlowski@samsung.com
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
 drivers/net/ethernet/chelsio/cxgb3/cxgb3_main.c | 6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/chelsio/cxgb3/cxgb3_main.c b/drivers/net/ethernet/chelsio/cxgb3/cxgb3_main.c
index 43da891..dc2e2ff 100644
--- a/drivers/net/ethernet/chelsio/cxgb3/cxgb3_main.c
+++ b/drivers/net/ethernet/chelsio/cxgb3/cxgb3_main.c
@@ -110,7 +110,7 @@ MODULE_DEVICE_TABLE(pci, cxgb3_pci_tbl);
 
 static int dflt_msg_enable = DFLT_MSG_ENABLE;
 
-module_param(dflt_msg_enable, int, 0644);
+module_param(dflt_msg_enable, int, S_IRUSR | S_IWUSR | S_IRGRP | S_IROTH);
 MODULE_PARM_DESC(dflt_msg_enable, "Chelsio T3 default message enable bitmap");
 
 /*
@@ -124,7 +124,7 @@ MODULE_PARM_DESC(dflt_msg_enable, "Chelsio T3 default message enable bitmap");
  */
 static int msi = 2;
 
-module_param(msi, int, 0644);
+module_param(msi, int, S_IRUSR | S_IWUSR | S_IRGRP | S_IROTH);
 MODULE_PARM_DESC(msi, "whether to use MSI or MSI-X");
 
 /*
@@ -134,7 +134,7 @@ MODULE_PARM_DESC(msi, "whether to use MSI or MSI-X");
 
 static int ofld_disable = 0;
 
-module_param(ofld_disable, int, 0644);
+module_param(ofld_disable, int, S_IRUSR | S_IWUSR | S_IRGRP | S_IROTH);
 MODULE_PARM_DESC(ofld_disable, "whether to enable offload at init time or not");
 
 /*
-- 
2.9.2
