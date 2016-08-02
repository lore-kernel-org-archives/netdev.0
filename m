From: Baole Ni <baolex.ni@intel.com>
Subject: [PATCH 0740/1285] Replace numeric parameter like 0444 with macro
Date: Tue,  2 Aug 2016 19:41:38 +0800
Message-ID: <20160802114138.31391-1-baolex.ni@intel.com>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	nico@fluxnic.net, davem@davemloft.net, robert.jarzmik@free.fr,
	mugunthanvnm@ti.com, felipe.balbi@linux.intel.com, fw@strlen.de,
	arnd@arndb.de, chuansheng.liu@intel.com, baolex.ni@intel.com
To: venza@brownhat.org, ecree@solarflare.com, bkenward@solarflare.com,
	linux-driver@qlogic.com, computersforpeace@gmail.com,
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
 drivers/net/ethernet/smsc/smc91x.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/smsc/smc91x.c b/drivers/net/ethernet/smsc/smc91x.c
index 18ac52d..a82e159 100644
--- a/drivers/net/ethernet/smsc/smc91x.c
+++ b/drivers/net/ethernet/smsc/smc91x.c
@@ -100,14 +100,14 @@ static const char version[] =
 # define SMC_NOWAIT		0
 #endif
 static int nowait = SMC_NOWAIT;
-module_param(nowait, int, 0400);
+module_param(nowait, int, S_IRUSR);
 MODULE_PARM_DESC(nowait, "set to 1 for no wait state");
 
 /*
  * Transmit timeout, default 5 seconds.
  */
 static int watchdog = 1000;
-module_param(watchdog, int, 0400);
+module_param(watchdog, int, S_IRUSR);
 MODULE_PARM_DESC(watchdog, "transmit timeout in milliseconds");
 
 MODULE_LICENSE("GPL");
-- 
2.9.2
