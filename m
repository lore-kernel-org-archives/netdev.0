From: Baole Ni <baolex.ni@intel.com>
Subject: [PATCH 0741/1285] Replace numeric parameter like 0444 with macro
Date: Tue,  2 Aug 2016 19:41:44 +0800
Message-ID: <20160802114144.31457-1-baolex.ni@intel.com>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	chuansheng.liu@intel.com, baolex.ni@intel.com,
	robert.jarzmik@free.fr, mugunthanvnm@ti.com,
	felipe.balbi@linux.intel.com, fw@strlen.de, arnd@arndb.de
To: florian@openwrt.org, ecree@solarflare.com, bkenward@solarflare.com,
	linux-driver@qlogic.com, computersforpeace@gmail.com,
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
 drivers/net/ethernet/ti/cpmac.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/ti/cpmac.c b/drivers/net/ethernet/ti/cpmac.c
index 7eef45e..6297fbb 100644
--- a/drivers/net/ethernet/ti/cpmac.c
+++ b/drivers/net/ethernet/ti/cpmac.c
@@ -52,8 +52,8 @@ static int debug_level = 8;
 static int dumb_switch;
 
 /* Next 2 are only used in cpmac_probe, so it's pointless to change them */
-module_param(debug_level, int, 0444);
-module_param(dumb_switch, int, 0444);
+module_param(debug_level, int, S_IRUSR | S_IRGRP | S_IROTH);
+module_param(dumb_switch, int, S_IRUSR | S_IRGRP | S_IROTH);
 
 MODULE_PARM_DESC(debug_level, "Number of NETIF_MSG bits to enable");
 MODULE_PARM_DESC(dumb_switch, "Assume switch is not connected to MDIO bus");
-- 
2.9.2
