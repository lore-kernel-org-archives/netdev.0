From: Baole Ni <baolex.ni@intel.com>
Subject: [PATCH 0728/1285] Replace numeric parameter like 0444 with macro
Date: Tue,  2 Aug 2016 19:40:32 +0800
Message-ID: <20160802114032.30594-1-baolex.ni@intel.com>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	davem@davemloft.net, fw@strlen.de, romieu@fr.zoreil.com,
	chuansheng.liu@intel.com, baolex.ni@intel.com, Baohua.Song@csr.com
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
 drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe_main.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe_main.c b/drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe_main.c
index 3cd87a4..38cc73d 100644
--- a/drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe_main.c
+++ b/drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe_main.c
@@ -2830,7 +2830,7 @@ MODULE_LICENSE("GPL");
 MODULE_VERSION(DRV_VERSION);
 MODULE_DEVICE_TABLE(pci, pch_gbe_pcidev_id);
 
-module_param(copybreak, uint, 0644);
+module_param(copybreak, uint, S_IRUSR | S_IWUSR | S_IRGRP | S_IROTH);
 MODULE_PARM_DESC(copybreak,
 	"Maximum size of packet that is copied to a new buffer on receive");
 
-- 
2.9.2
