From: Baole Ni <baolex.ni@intel.com>
Subject: [PATCH 0732/1285] Replace numeric parameter like 0444 with macro
Date: Tue,  2 Aug 2016 19:40:53 +0800
Message-ID: <20160802114053.30858-1-baolex.ni@intel.com>
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
 drivers/net/ethernet/sfc/ef10.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/sfc/ef10.c b/drivers/net/ethernet/sfc/ef10.c
index 1f30912..fcf06c5 100644
--- a/drivers/net/ethernet/sfc/ef10.c
+++ b/drivers/net/ethernet/sfc/ef10.c
@@ -275,9 +275,9 @@ static ssize_t efx_ef10_show_primary_flag(struct device *dev,
 		       ? 1 : 0);
 }
 
-static DEVICE_ATTR(link_control_flag, 0444, efx_ef10_show_link_control_flag,
+static DEVICE_ATTR(link_control_flag, S_IRUSR | S_IRGRP | S_IROTH, efx_ef10_show_link_control_flag,
 		   NULL);
-static DEVICE_ATTR(primary_flag, 0444, efx_ef10_show_primary_flag, NULL);
+static DEVICE_ATTR(primary_flag, S_IRUSR | S_IRGRP | S_IROTH, efx_ef10_show_primary_flag, NULL);
 
 static int efx_ef10_probe(struct efx_nic *efx)
 {
-- 
2.9.2
