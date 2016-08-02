From: Baole Ni <baolex.ni@intel.com>
Subject: [PATCH 0747/1285] Replace numeric parameter like 0444 with macro
Date: Tue,  2 Aug 2016 19:42:20 +0800
Message-ID: <20160802114220.31860-1-baolex.ni@intel.com>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	chuansheng.liu@intel.com, baolex.ni@intel.com,
	linville@tuxdriver.com, pshelar@nicira.com, jbenc@redhat.com,
	daniel@iogearbox.net, hannes@stressinduktion.org,
	tom@herbertland.com, aduyck@mirantis.com
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
 drivers/net/irda/mcs7780.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/irda/mcs7780.c b/drivers/net/irda/mcs7780.c
index bca6a1e..f43b521 100644
--- a/drivers/net/irda/mcs7780.c
+++ b/drivers/net/irda/mcs7780.c
@@ -89,12 +89,12 @@ MODULE_PARM_DESC(receive_mode,
 		 "Receive mode of the device (1:fast, 0:slow, default:1)");
 
 static int sir_tweak = 1;
-module_param(sir_tweak, int, 0444);
+module_param(sir_tweak, int, S_IRUSR | S_IRGRP | S_IROTH);
 MODULE_PARM_DESC(sir_tweak,
 		 "Default pulse width (1:1.6us, 0:3/16 bit, default:1).");
 
 static int transceiver_type = MCS_TSC_VISHAY;
-module_param(transceiver_type, int, 0444);
+module_param(transceiver_type, int, S_IRUSR | S_IRGRP | S_IROTH);
 MODULE_PARM_DESC(transceiver_type, "IR transceiver type, see mcs7780.h.");
 
 static struct usb_driver mcs_driver = {
-- 
2.9.2
