From: Baole Ni <baolex.ni@intel.com>
Subject: [PATCH 0736/1285] Replace numeric parameter like 0444 with macro
Date: Tue,  2 Aug 2016 19:41:13 +0800
Message-ID: <20160802114113.31123-1-baolex.ni@intel.com>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	chuansheng.liu@intel.com, baolex.ni@intel.com,
	romieu@fr.zoreil.com, Baohua.Song@csr.com
To: linux-net-drivers@solarflare.com, ecree@solarflare.com,
	bkenward@solarflare.com, linux-driver@qlogic.com,
	computersforpeace@gmail.com, m.chehab@samsung.com,
	pawel@osciak.com, m.szyprowski@samsung.com,
	kyungmin.park@samsung.com, k.kozlowski@samsung.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga04.intel.com ([192.55.52.120]:59996 "EHLO mga04.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S934406AbcHBMSz (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 2 Aug 2016 08:18:55 -0400
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
 drivers/net/ethernet/sfc/rx.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/sfc/rx.c b/drivers/net/ethernet/sfc/rx.c
index 02b0b527..d1d01e0 100644
--- a/drivers/net/ethernet/sfc/rx.c
+++ b/drivers/net/ethernet/sfc/rx.c
@@ -830,7 +830,7 @@ void efx_remove_rx_queue(struct efx_rx_queue *rx_queue)
 }
 
 
-module_param(rx_refill_threshold, uint, 0444);
+module_param(rx_refill_threshold, uint, S_IRUSR | S_IRGRP | S_IROTH);
 MODULE_PARM_DESC(rx_refill_threshold,
 		 "RX descriptor ring refill threshold (%)");
 
-- 
2.9.2
