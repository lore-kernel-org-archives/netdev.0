From: Baole Ni <baolex.ni@intel.com>
Subject: [PATCH 0716/1285] Replace numeric parameter like 0444 with macro
Date: Tue,  2 Aug 2016 19:39:23 +0800
Message-ID: <20160802113923.29795-1-baolex.ni@intel.com>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	davem@davemloft.net, mugunthanvnm@ti.com, marcel@ziswiler.com,
	felipe.balbi@linux.intel.com, fw@strlen.de, harvey.hunt@imgtec.com,
	robert.jarzmik@free.fr, Baohua.Song@csr.com,
	chuansheng.liu@intel.com, baolex.ni@intel.com
To: leedom@chelsio.com, rric@kernel.org,
	felix.manlunas@caviumnetworks.com,
	raghu.vatsavayi@caviumnetworks.com, computersforpeace@gmail.com,
	m.chehab@samsung.com, pawel@osciak.com, m.szyprowski@samsung.com,
	kyungmin.park@samsung.com, k.kozlowski@samsung.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga04.intel.com ([192.55.52.120]:51141 "EHLO mga04.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S934298AbcHBMRh (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 2 Aug 2016 08:17:37 -0400
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
 drivers/net/ethernet/davicom/dm9000.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/davicom/dm9000.c b/drivers/net/ethernet/davicom/dm9000.c
index 1471e16..0680085 100644
--- a/drivers/net/ethernet/davicom/dm9000.c
+++ b/drivers/net/ethernet/davicom/dm9000.c
@@ -57,14 +57,14 @@
  * Transmit timeout, default 5 seconds.
  */
 static int watchdog = 5000;
-module_param(watchdog, int, 0400);
+module_param(watchdog, int, S_IRUSR);
 MODULE_PARM_DESC(watchdog, "transmit timeout in milliseconds");
 
 /*
  * Debug messages level
  */
 static int debug;
-module_param(debug, int, 0644);
+module_param(debug, int, S_IRUSR | S_IWUSR | S_IRGRP | S_IROTH);
 MODULE_PARM_DESC(debug, "dm9000 debug level (0-4)");
 
 /* DM9000 register address locking.
-- 
2.9.2
