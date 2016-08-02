From: Baole Ni <baolex.ni@intel.com>
Subject: [PATCH 0738/1285] Replace numeric parameter like 0444 with macro
Date: Tue,  2 Aug 2016 19:41:23 +0800
Message-ID: <20160802114123.31255-1-baolex.ni@intel.com>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	chuansheng.liu@intel.com, baolex.ni@intel.com,
	romieu@fr.zoreil.com, Baohua.Song@csr.com
To: venza@brownhat.org, ecree@solarflare.com, bkenward@solarflare.com,
	linux-driver@qlogic.com, computersforpeace@gmail.com,
	m.chehab@samsung.com, pawel@osciak.com, m.szyprowski@samsung.com,
	kyungmin.park@samsung.com, k.kozlowski@samsung.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:52450 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S934423AbcHBMTF (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 2 Aug 2016 08:19:05 -0400
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
 drivers/net/ethernet/sis/sis900.c | 6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/sis/sis900.c b/drivers/net/ethernet/sis/sis900.c
index 95001ee4..96eef0d 100644
--- a/drivers/net/ethernet/sis/sis900.c
+++ b/drivers/net/ethernet/sis/sis900.c
@@ -197,9 +197,9 @@ MODULE_AUTHOR("Jim Huang <cmhuang@sis.com.tw>, Ollie Lho <ollie@sis.com.tw>");
 MODULE_DESCRIPTION("SiS 900 PCI Fast Ethernet driver");
 MODULE_LICENSE("GPL");
 
-module_param(multicast_filter_limit, int, 0444);
-module_param(max_interrupt_work, int, 0444);
-module_param(sis900_debug, int, 0444);
+module_param(multicast_filter_limit, int, S_IRUSR | S_IRGRP | S_IROTH);
+module_param(max_interrupt_work, int, S_IRUSR | S_IRGRP | S_IROTH);
+module_param(sis900_debug, int, S_IRUSR | S_IRGRP | S_IROTH);
 MODULE_PARM_DESC(multicast_filter_limit, "SiS 900/7016 maximum number of filtered multicast addresses");
 MODULE_PARM_DESC(max_interrupt_work, "SiS 900/7016 maximum events handled per interrupt");
 MODULE_PARM_DESC(sis900_debug, "SiS 900/7016 bitmapped debugging message level");
-- 
2.9.2
