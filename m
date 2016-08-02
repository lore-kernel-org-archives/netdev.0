From: Baole Ni <baolex.ni@intel.com>
Subject: [PATCH 0708/1285] Replace numeric parameter like 0444 with macro
Date: Tue,  2 Aug 2016 19:38:38 +0800
Message-ID: <20160802113838.29254-1-baolex.ni@intel.com>
Cc: linux-can@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, chuansheng.liu@intel.com,
	baolex.ni@intel.com, grundler@chromium.org, lporzio@micron.com
To: wg@grandegger.com, mkl@pengutronix.de, gospo@cumulusnetworks.com,
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
 drivers/net/can/led.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/can/led.c b/drivers/net/can/led.c
index c1b6676..c602b9e 100644
--- a/drivers/net/can/led.c
+++ b/drivers/net/can/led.c
@@ -17,7 +17,7 @@
 #include <linux/can/led.h>
 
 static unsigned long led_delay = 50;
-module_param(led_delay, ulong, 0644);
+module_param(led_delay, ulong, S_IRUSR | S_IWUSR | S_IRGRP | S_IROTH);
 MODULE_PARM_DESC(led_delay,
 		"blink delay time for activity leds (msecs, default: 50).");
 
-- 
2.9.2
