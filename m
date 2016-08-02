From: Baole Ni <baolex.ni@intel.com>
Subject: [PATCH 0714/1285] Replace numeric parameter like 0444 with macro
Date: Tue,  2 Aug 2016 19:39:11 +0800
Message-ID: <20160802113911.29661-1-baolex.ni@intel.com>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	chuansheng.liu@intel.com, baolex.ni@intel.com, mugunthanvnm@ti.com,
	felipe.balbi@linux.intel.com, fw@strlen.de
To: hariprasad@chelsio.com, rric@kernel.org,
	felix.manlunas@caviumnetworks.com,
	raghu.vatsavayi@caviumnetworks.com, computersforpeace@gmail.com,
	m.chehab@samsung.com, pawel@osciak.com, m.szyprowski@samsung.com,
	kyungmin.park@samsung.com, k.kozlowski@samsung.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([192.55.52.115]:28885 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S934287AbcHBMRg (ORCPT <rfc822;netdev@vger.kernel.org>);
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
 drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c | 14 +++++++-------
 1 file changed, 7 insertions(+), 7 deletions(-)

diff --git a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
index 477db47..1fa15e5 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
+++ b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
@@ -161,13 +161,13 @@ MODULE_FIRMWARE(FW6_FNAME);
  */
 static uint force_init;
 
-module_param(force_init, uint, 0644);
+module_param(force_init, uint, S_IRUSR | S_IWUSR | S_IRGRP | S_IROTH);
 MODULE_PARM_DESC(force_init, "Forcibly become Master PF and initialize adapter,"
 		 "deprecated parameter");
 
 static int dflt_msg_enable = DFLT_MSG_ENABLE;
 
-module_param(dflt_msg_enable, int, 0644);
+module_param(dflt_msg_enable, int, S_IRUSR | S_IWUSR | S_IRGRP | S_IROTH);
 MODULE_PARM_DESC(dflt_msg_enable, "Chelsio T4 default message enable bitmap, "
 		 "deprecated parameter");
 
@@ -182,7 +182,7 @@ MODULE_PARM_DESC(dflt_msg_enable, "Chelsio T4 default message enable bitmap, "
  */
 static int msi = 2;
 
-module_param(msi, int, 0644);
+module_param(msi, int, S_IRUSR | S_IWUSR | S_IRGRP | S_IROTH);
 MODULE_PARM_DESC(msi, "whether to use INTx (0), MSI (1) or MSI-X (2)");
 
 /*
@@ -205,7 +205,7 @@ static int rx_dma_offset = 2;
  */
 static unsigned int num_vf[NUM_OF_PF_WITH_SRIOV];
 
-module_param_array(num_vf, uint, NULL, 0644);
+module_param_array(num_vf, uint, NULL, S_IRUSR | S_IWUSR | S_IRGRP | S_IROTH);
 MODULE_PARM_DESC(num_vf, "number of VFs for each of PFs 0-3");
 #endif
 
@@ -216,7 +216,7 @@ MODULE_PARM_DESC(num_vf, "number of VFs for each of PFs 0-3");
  * Default: select_queue=0
  */
 static int select_queue;
-module_param(select_queue, int, 0644);
+module_param(select_queue, int, S_IRUSR | S_IWUSR | S_IRGRP | S_IROTH);
 MODULE_PARM_DESC(select_queue,
 		 "Select between kernel provided method of selecting or driver method of selecting TX queue. Default is kernel method.");
 
@@ -369,14 +369,14 @@ void t4_os_portmod_changed(const struct adapter *adap, int port_id)
 }
 
 int dbfifo_int_thresh = 10; /* 10 == 640 entry threshold */
-module_param(dbfifo_int_thresh, int, 0644);
+module_param(dbfifo_int_thresh, int, S_IRUSR | S_IWUSR | S_IRGRP | S_IROTH);
 MODULE_PARM_DESC(dbfifo_int_thresh, "doorbell fifo interrupt threshold");
 
 /*
  * usecs to sleep while draining the dbfifo
  */
 static int dbfifo_drain_delay = 1000;
-module_param(dbfifo_drain_delay, int, 0644);
+module_param(dbfifo_drain_delay, int, S_IRUSR | S_IWUSR | S_IRGRP | S_IROTH);
 MODULE_PARM_DESC(dbfifo_drain_delay,
 		 "usecs to sleep while draining the dbfifo");
 
-- 
2.9.2
