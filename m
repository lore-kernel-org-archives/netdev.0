From: Baole Ni <baolex.ni@intel.com>
Subject: [PATCH 0737/1285] Replace numeric parameter like 0444 with macro
Date: Tue,  2 Aug 2016 19:41:18 +0800
Message-ID: <20160802114118.31189-1-baolex.ni@intel.com>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	chuansheng.liu@intel.com, baolex.ni@intel.com,
	romieu@fr.zoreil.com, Baohua.Song@csr.com
To: linux-net-drivers@solarflare.com, ecree@solarflare.com,
	bkenward@solarflare.com, linux-driver@qlogic.com,
	computersforpeace@gmail.com, m.chehab@samsung.com,
	pawel@osciak.com, m.szyprowski@samsung.com,
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
 drivers/net/ethernet/sfc/siena_sriov.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/sfc/siena_sriov.c b/drivers/net/ethernet/sfc/siena_sriov.c
index da7b94f..010bf28 100644
--- a/drivers/net/ethernet/sfc/siena_sriov.c
+++ b/drivers/net/ethernet/sfc/siena_sriov.c
@@ -175,12 +175,12 @@ struct efx_endpoint_page {
 
 /* VFs can only use this many transmit channels */
 static unsigned int vf_max_tx_channels = 2;
-module_param(vf_max_tx_channels, uint, 0444);
+module_param(vf_max_tx_channels, uint, S_IRUSR | S_IRGRP | S_IROTH);
 MODULE_PARM_DESC(vf_max_tx_channels,
 		 "Limit the number of TX channels VFs can use");
 
 static int max_vfs = -1;
-module_param(max_vfs, int, 0444);
+module_param(max_vfs, int, S_IRUSR | S_IRGRP | S_IROTH);
 MODULE_PARM_DESC(max_vfs,
 		 "Reduce the number of VFs initialized by the driver");
 
-- 
2.9.2
