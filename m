From: Baole Ni <baolex.ni@intel.com>
Subject: [PATCH 0721/1285] Replace numeric parameter like 0444 with macro
Date: Tue,  2 Aug 2016 19:39:51 +0800
Message-ID: <20160802113951.30127-1-baolex.ni@intel.com>
Cc: intel-wired-lan@lists.osuosl.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, chuansheng.liu@intel.com,
	baolex.ni@intel.com, fw@strlen.de, davem@davemloft.net,
	Baohua.Song@csr.com
To: jeffrey.t.kirsher@intel.com, benh@kernel.crashing.org,
	paulus@samba.org, mpe@ellerman.id.au, computersforpeace@gmail.com,
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
 drivers/net/ethernet/intel/ixgb/ixgb_main.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/intel/ixgb/ixgb_main.c b/drivers/net/ethernet/intel/ixgb/ixgb_main.c
index 31f9145..ccc30c6 100644
--- a/drivers/net/ethernet/intel/ixgb/ixgb_main.c
+++ b/drivers/net/ethernet/intel/ixgb/ixgb_main.c
@@ -41,7 +41,7 @@ static const char ixgb_copyright[] = "Copyright (c) 1999-2008 Intel Corporation.
 
 #define IXGB_CB_LENGTH 256
 static unsigned int copybreak __read_mostly = IXGB_CB_LENGTH;
-module_param(copybreak, uint, 0644);
+module_param(copybreak, uint, S_IRUSR | S_IWUSR | S_IRGRP | S_IROTH);
 MODULE_PARM_DESC(copybreak,
 	"Maximum size of packet that is copied to a new buffer on receive");
 
-- 
2.9.2
