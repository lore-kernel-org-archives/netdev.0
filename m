From: Baole Ni <baolex.ni@intel.com>
Subject: [PATCH 0734/1285] Replace numeric parameter like 0444 with macro
Date: Tue,  2 Aug 2016 19:41:04 +0800
Message-ID: <20160802114104.30990-1-baolex.ni@intel.com>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	chuansheng.liu@intel.com, baolex.ni@intel.com,
	romieu@fr.zoreil.com, Baohua.Song@csr.com
To: linux-net-drivers@solarflare.com, ecree@solarflare.com,
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
 drivers/net/ethernet/sfc/falcon_boards.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/sfc/falcon_boards.c b/drivers/net/ethernet/sfc/falcon_boards.c
index 1736f4b..5ace2ac 100644
--- a/drivers/net/ethernet/sfc/falcon_boards.c
+++ b/drivers/net/ethernet/sfc/falcon_boards.c
@@ -399,7 +399,7 @@ static ssize_t set_phy_flash_cfg(struct device *dev,
 	return err ? err : count;
 }
 
-static DEVICE_ATTR(phy_flash_cfg, 0644, show_phy_flash_cfg, set_phy_flash_cfg);
+static DEVICE_ATTR(phy_flash_cfg, S_IRUSR | S_IWUSR | S_IRGRP | S_IROTH, show_phy_flash_cfg, set_phy_flash_cfg);
 
 static void sfe4001_fini(struct efx_nic *efx)
 {
-- 
2.9.2
