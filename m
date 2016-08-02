From: Baole Ni <baolex.ni@intel.com>
Subject: [PATCH 0743/1285] Replace numeric parameter like 0444 with macro
Date: Tue,  2 Aug 2016 19:41:54 +0800
Message-ID: <20160802114154.31589-1-baolex.ni@intel.com>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	chuansheng.liu@intel.com, baolex.ni@intel.com,
	robert.jarzmik@free.fr, mugunthanvnm@ti.com,
	felipe.balbi@linux.intel.com, fw@strlen.de, arnd@arndb.de
To: kou.ishizaki@toshiba.co.jp, ecree@solarflare.com,
	bkenward@solarflare.com, linux-driver@qlogic.com,
	computersforpeace@gmail.com, m.chehab@samsung.com,
	pawel@osciak.com, m.szyprowski@samsung.com,
	kyungmin.park@samsung.com, k.kozlowski@samsung.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:49040 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S934463AbcHBMTg (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 2 Aug 2016 08:19:36 -0400
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
 drivers/net/ethernet/toshiba/spider_net.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/toshiba/spider_net.c b/drivers/net/ethernet/toshiba/spider_net.c
index 36a6e8b..2e246d6 100644
--- a/drivers/net/ethernet/toshiba/spider_net.c
+++ b/drivers/net/ethernet/toshiba/spider_net.c
@@ -62,8 +62,8 @@ MODULE_FIRMWARE(SPIDER_NET_FIRMWARE_NAME);
 static int rx_descriptors = SPIDER_NET_RX_DESCRIPTORS_DEFAULT;
 static int tx_descriptors = SPIDER_NET_TX_DESCRIPTORS_DEFAULT;
 
-module_param(rx_descriptors, int, 0444);
-module_param(tx_descriptors, int, 0444);
+module_param(rx_descriptors, int, S_IRUSR | S_IRGRP | S_IROTH);
+module_param(tx_descriptors, int, S_IRUSR | S_IRGRP | S_IROTH);
 
 MODULE_PARM_DESC(rx_descriptors, "number of descriptors used " \
 		 "in rx chains");
-- 
2.9.2
