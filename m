From: Baole Ni <baolex.ni@intel.com>
Subject: [PATCH 0726/1285] Replace numeric parameter like 0444 with macro
Date: Tue,  2 Aug 2016 19:40:20 +0800
Message-ID: <20160802114020.30460-1-baolex.ni@intel.com>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	davem@davemloft.net, harvey.hunt@imgtec.com,
	chuansheng.liu@intel.com, baolex.ni@intel.com, Baohua.Song@csr.com
To: matanb@mellanox.com, leonro@mellanox.com, paulus@samba.org,
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
 drivers/net/ethernet/micrel/ks8695net.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/micrel/ks8695net.c b/drivers/net/ethernet/micrel/ks8695net.c
index 20cb85b..a2ae180 100644
--- a/drivers/net/ethernet/micrel/ks8695net.c
+++ b/drivers/net/ethernet/micrel/ks8695net.c
@@ -1629,5 +1629,5 @@ MODULE_DESCRIPTION("Micrel KS8695 (Centaur) Ethernet driver");
 MODULE_LICENSE("GPL");
 MODULE_ALIAS("platform:" MODULENAME);
 
-module_param(watchdog, int, 0400);
+module_param(watchdog, int, S_IRUSR);
 MODULE_PARM_DESC(watchdog, "transmit timeout in milliseconds");
-- 
2.9.2
