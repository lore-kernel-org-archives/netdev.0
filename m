From: Baole Ni <baolex.ni@intel.com>
Subject: [PATCH 0748/1285] Replace numeric parameter like 0444 with macro
Date: Tue,  2 Aug 2016 19:42:27 +0800
Message-ID: <20160802114227.31928-1-baolex.ni@intel.com>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	nab@linux-iscsi.org, chuansheng.liu@intel.com, baolex.ni@intel.com,
	pshelar@nicira.com, jbenc@redhat.com, daniel@iogearbox.net,
	hannes@stressinduktion.org, tom@herbertland.com,
	aduyck@mirantis.com
To: samuel@sortiz.org, soren.brinkmann@xilinx.com,
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
 drivers/net/netconsole.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/netconsole.c b/drivers/net/netconsole.c
index 06ee639..c5e543e 100644
--- a/drivers/net/netconsole.c
+++ b/drivers/net/netconsole.c
@@ -61,7 +61,7 @@ module_param_string(netconsole, config, MAX_PARAM_LENGTH, 0);
 MODULE_PARM_DESC(netconsole, " netconsole=[src-port]@[src-ip]/[dev],[tgt-port]@<tgt-ip>/[tgt-macaddr]");
 
 static bool oops_only = false;
-module_param(oops_only, bool, 0600);
+module_param(oops_only, bool, S_IRUSR | S_IWUSR);
 MODULE_PARM_DESC(oops_only, "Only log oops messages");
 
 #ifndef	MODULE
-- 
2.9.2
