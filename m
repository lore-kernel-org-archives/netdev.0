From: Baole Ni <baolex.ni-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
Subject: [PATCH 0770/1285] Replace numeric parameter like 0444 with macro
Date: Tue,  2 Aug 2016 19:44:42 +0800
Message-ID: <20160802114442.999-1-baolex.ni@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: lars-Qo5EllUWu/uELgA04lAiVw@public.gmane.org, johannes.berg-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
 linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
 baolex.ni-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org, baijiaju1990-9Onoh4P/yGk@public.gmane.org, b43-dev-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org,
 chuansheng.liu-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org
To: kvalo-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org, bkenward-s/n/eUQHGBpZroRs9YW3xA@public.gmane.org, linux-driver-h88ZbnxC6KDQT0dZR+AlfA@public.gmane.org,
 computersforpeace-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, m.chehab-Sze3O3UU22JBDgjK7y7TUQ@public.gmane.org, pawel-FA/gS7QP4orQT0dZR+AlfA@public.gmane.org,
 m.szyprowski-Sze3O3UU22JBDgjK7y7TUQ@public.gmane.org, kyungmin.park-Sze3O3UU22JBDgjK7y7TUQ@public.gmane.org,
 k.kozlowski-Sze3O3UU22JBDgjK7y7TUQ@public.gmane.org
Return-path: <b43-dev-bounces+gldbd-bcm43xx-dev=gmane.org-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org>
List-Unsubscribe: <http://lists.infradead.org/mailman/options/b43-dev>,
 <mailto:b43-dev-request-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.infradead.org/pipermail/b43-dev/>
List-Post: <mailto:b43-dev-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org>
List-Help: <mailto:b43-dev-request-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org?subject=help>
List-Subscribe: <http://lists.infradead.org/mailman/listinfo/b43-dev>,
 <mailto:b43-dev-request-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org?subject=subscribe>
Sender: "b43-dev" <b43-dev-bounces-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org>
Errors-To: b43-dev-bounces+gldbd-bcm43xx-dev=gmane.org-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org
List-Id: netdev.vger.kernel.org

I find that the developers often just specified the numeric value
when calling a macro which is defined with a parameter for access permission.
As we know, these numeric value for access permission have had the corresponding macro,
and that using macro can improve the robustness and readability of the code,
thus, I suggest replacing the numeric parameter with the macro.

Signed-off-by: Chuansheng Liu <chuansheng.liu-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
Signed-off-by: Baole Ni <baolex.ni-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
---
 drivers/net/wireless/broadcom/b43/main.c | 20 ++++++++++----------
 1 file changed, 10 insertions(+), 10 deletions(-)

diff --git a/drivers/net/wireless/broadcom/b43/main.c b/drivers/net/wireless/broadcom/b43/main.c
index 4ee5c58..cadd5bd 100644
--- a/drivers/net/wireless/broadcom/b43/main.c
+++ b/drivers/net/wireless/broadcom/b43/main.c
@@ -76,44 +76,44 @@ MODULE_FIRMWARE("b43/ucode5.fw");
 MODULE_FIRMWARE("b43/ucode9.fw");
 
 static int modparam_bad_frames_preempt;
-module_param_named(bad_frames_preempt, modparam_bad_frames_preempt, int, 0444);
+module_param_named(bad_frames_preempt, modparam_bad_frames_preempt, int, S_IRUSR | S_IRGRP | S_IROTH);
 MODULE_PARM_DESC(bad_frames_preempt,
 		 "enable(1) / disable(0) Bad Frames Preemption");
 
 static char modparam_fwpostfix[16];
-module_param_string(fwpostfix, modparam_fwpostfix, 16, 0444);
+module_param_string(fwpostfix, modparam_fwpostfix, 16, S_IRUSR | S_IRGRP | S_IROTH);
 MODULE_PARM_DESC(fwpostfix, "Postfix for the .fw files to load.");
 
 static int modparam_hwpctl;
-module_param_named(hwpctl, modparam_hwpctl, int, 0444);
+module_param_named(hwpctl, modparam_hwpctl, int, S_IRUSR | S_IRGRP | S_IROTH);
 MODULE_PARM_DESC(hwpctl, "Enable hardware-side power control (default off)");
 
 static int modparam_nohwcrypt;
-module_param_named(nohwcrypt, modparam_nohwcrypt, int, 0444);
+module_param_named(nohwcrypt, modparam_nohwcrypt, int, S_IRUSR | S_IRGRP | S_IROTH);
 MODULE_PARM_DESC(nohwcrypt, "Disable hardware encryption.");
 
 static int modparam_hwtkip;
-module_param_named(hwtkip, modparam_hwtkip, int, 0444);
+module_param_named(hwtkip, modparam_hwtkip, int, S_IRUSR | S_IRGRP | S_IROTH);
 MODULE_PARM_DESC(hwtkip, "Enable hardware tkip.");
 
 static int modparam_qos = 1;
-module_param_named(qos, modparam_qos, int, 0444);
+module_param_named(qos, modparam_qos, int, S_IRUSR | S_IRGRP | S_IROTH);
 MODULE_PARM_DESC(qos, "Enable QOS support (default on)");
 
 static int modparam_btcoex = 1;
-module_param_named(btcoex, modparam_btcoex, int, 0444);
+module_param_named(btcoex, modparam_btcoex, int, S_IRUSR | S_IRGRP | S_IROTH);
 MODULE_PARM_DESC(btcoex, "Enable Bluetooth coexistence (default on)");
 
 int b43_modparam_verbose = B43_VERBOSITY_DEFAULT;
-module_param_named(verbose, b43_modparam_verbose, int, 0644);
+module_param_named(verbose, b43_modparam_verbose, int, S_IRUSR | S_IWUSR | S_IRGRP | S_IROTH);
 MODULE_PARM_DESC(verbose, "Log message verbosity: 0=error, 1=warn, 2=info(default), 3=debug");
 
 static int b43_modparam_pio = 0;
-module_param_named(pio, b43_modparam_pio, int, 0644);
+module_param_named(pio, b43_modparam_pio, int, S_IRUSR | S_IWUSR | S_IRGRP | S_IROTH);
 MODULE_PARM_DESC(pio, "Use PIO accesses by default: 0=DMA, 1=PIO");
 
 static int modparam_allhwsupport = !IS_ENABLED(CONFIG_BRCMSMAC);
-module_param_named(allhwsupport, modparam_allhwsupport, int, 0444);
+module_param_named(allhwsupport, modparam_allhwsupport, int, S_IRUSR | S_IRGRP | S_IROTH);
 MODULE_PARM_DESC(allhwsupport, "Enable support for all hardware (even it if overlaps with the brcmsmac driver)");
 
 #ifdef CONFIG_B43_BCMA
-- 
2.9.2
