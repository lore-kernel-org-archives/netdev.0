From: Baole Ni <baolex.ni@intel.com>
Subject: [PATCH 0744/1285] Replace numeric parameter like 0444 with macro
Date: Tue,  2 Aug 2016 19:41:59 +0800
Message-ID: <20160802114159.31658-1-baolex.ni@intel.com>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	chuansheng.liu@intel.com, baolex.ni@intel.com,
	robert.jarzmik@free.fr, mugunthanvnm@ti.com,
	felipe.balbi@linux.intel.com, fw@strlen.de, arnd@arndb.de
To: romieu@fr.zoreil.com, ecree@solarflare.com,
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
 drivers/net/ethernet/via/via-velocity.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/via/via-velocity.c b/drivers/net/ethernet/via/via-velocity.c
index f38696c..d3d287e 100644
--- a/drivers/net/ethernet/via/via-velocity.c
+++ b/drivers/net/ethernet/via/via-velocity.c
@@ -358,7 +358,7 @@ VELOCITY_PARAM(speed_duplex, "Setting the speed and duplex mode");
 VELOCITY_PARAM(wol_opts, "Wake On Lan options");
 
 static int rx_copybreak = 200;
-module_param(rx_copybreak, int, 0644);
+module_param(rx_copybreak, int, S_IRUSR | S_IWUSR | S_IRGRP | S_IROTH);
 MODULE_PARM_DESC(rx_copybreak, "Copy breakpoint for copy-only-tiny-frames");
 
 /*
-- 
2.9.2
