From: Baole Ni <baolex.ni@intel.com>
Subject: [PATCH 0759/1285] Replace numeric parameter like 0444 with macro
Date: Tue,  2 Aug 2016 19:43:32 +0800
Message-ID: <20160802114332.32716-1-baolex.ni@intel.com>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	chuansheng.liu@intel.com, baolex.ni@intel.com, tgraf@suug.ch,
	hannes@stressinduktion.org, daniel@iogearbox.net, pabeni@redhat.com
To: inaky.perez-gonzalez@intel.com, linux-wimax@intel.com,
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
 drivers/net/wimax/i2400m/control.c | 6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/drivers/net/wimax/i2400m/control.c b/drivers/net/wimax/i2400m/control.c
index 4c41790..e288326 100644
--- a/drivers/net/wimax/i2400m/control.c
+++ b/drivers/net/wimax/i2400m/control.c
@@ -86,14 +86,14 @@
 #include "debug-levels.h"
 
 static int i2400m_idle_mode_disabled;/* 0 (idle mode enabled) by default */
-module_param_named(idle_mode_disabled, i2400m_idle_mode_disabled, int, 0644);
+module_param_named(idle_mode_disabled, i2400m_idle_mode_disabled, int, S_IRUSR | S_IWUSR | S_IRGRP | S_IROTH);
 MODULE_PARM_DESC(idle_mode_disabled,
 		 "If true, the device will not enable idle mode negotiation "
 		 "with the base station (when connected) to save power.");
 
 /* 0 (power saving enabled) by default */
 static int i2400m_power_save_disabled;
-module_param_named(power_save_disabled, i2400m_power_save_disabled, int, 0644);
+module_param_named(power_save_disabled, i2400m_power_save_disabled, int, S_IRUSR | S_IWUSR | S_IRGRP | S_IROTH);
 MODULE_PARM_DESC(power_save_disabled,
 		 "If true, the driver will not tell the device to enter "
 		 "power saving mode when it reports it is ready for it. "
@@ -101,7 +101,7 @@ MODULE_PARM_DESC(power_save_disabled,
 		 "saving).");
 
 static int i2400m_passive_mode;	/* 0 (passive mode disabled) by default */
-module_param_named(passive_mode, i2400m_passive_mode, int, 0644);
+module_param_named(passive_mode, i2400m_passive_mode, int, S_IRUSR | S_IWUSR | S_IRGRP | S_IROTH);
 MODULE_PARM_DESC(passive_mode,
 		 "If true, the driver will not do any device setup "
 		 "and leave it up to user space, who must be properly "
-- 
2.9.2
