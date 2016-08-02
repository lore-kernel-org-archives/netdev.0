From: Baole Ni <baolex.ni@intel.com>
Subject: [PATCH 0868/1285] Replace numeric parameter like 0444 with macro
Date: Tue,  2 Aug 2016 19:53:40 +0800
Message-ID: <20160802115340.7846-1-baolex.ni@intel.com>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	chuansheng.liu@intel.com, baolex.ni@intel.com
To: richardcochran@gmail.com, benh@kernel.crashing.org,
	paulus@samba.org, mpe@ellerman.id.au, dwmw2@infradead.org,
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
 drivers/ptp/ptp_pch.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/ptp/ptp_pch.c b/drivers/ptp/ptp_pch.c
index 3aa22ae..8bbcdb6 100644
--- a/drivers/ptp/ptp_pch.c
+++ b/drivers/ptp/ptp_pch.c
@@ -727,7 +727,7 @@ module_init(ptp_pch_init);
 module_exit(ptp_pch_exit);
 
 module_param_string(station,
-		    pch_param.station, sizeof(pch_param.station), 0444);
+		    pch_param.station, sizeof(pch_param.station), S_IRUSR | S_IRGRP | S_IROTH);
 MODULE_PARM_DESC(station,
 	 "IEEE 1588 station address to use - colon separated hex values");
 
-- 
2.9.2
