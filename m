From: Baole Ni <baolex.ni@intel.com>
Subject: [PATCH 0727/1285] Replace numeric parameter like 0444 with macro
Date: Tue,  2 Aug 2016 19:40:25 +0800
Message-ID: <20160802114025.30526-1-baolex.ni@intel.com>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	chuansheng.liu@intel.com, baolex.ni@intel.com, davem@davemloft.net,
	Baohua.Song@csr.com
To: hykim@myri.com, leonro@mellanox.com, paulus@samba.org,
	mpe@ellerman.id.au, computersforpeace@gmail.com,
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
 drivers/net/ethernet/myricom/myri10ge/myri10ge.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/myricom/myri10ge/myri10ge.c b/drivers/net/ethernet/myricom/myri10ge/myri10ge.c
index 6d1a956..cdbad43 100644
--- a/drivers/net/ethernet/myricom/myri10ge/myri10ge.c
+++ b/drivers/net/ethernet/myricom/myri10ge/myri10ge.c
@@ -288,7 +288,7 @@ MODULE_PARM_DESC(myri10ge_fw_name, "Firmware image name");
 static char *myri10ge_fw_names[MYRI10GE_MAX_BOARDS] =
     {[0 ... (MYRI10GE_MAX_BOARDS - 1)] = NULL };
 module_param_array_named(myri10ge_fw_names, myri10ge_fw_names, charp, NULL,
-			 0444);
+			 S_IRUSR | S_IRGRP | S_IROTH);
 MODULE_PARM_DESC(myri10ge_fw_name, "Firmware image names per board");
 
 static int myri10ge_ecrc_enable = 1;
-- 
2.9.2
