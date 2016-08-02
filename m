From: Baole Ni <baolex.ni-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
Subject: [PATCH 0774/1285] Replace numeric parameter like 0444 with macro
Date: Tue,  2 Aug 2016 19:45:07 +0800
Message-ID: <20160802114507.1297-1-baolex.ni@intel.com>
Cc: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, chuansheng.liu-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org,
	baolex.ni-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org, lars-Qo5EllUWu/uELgA04lAiVw@public.gmane.org, johannes.berg-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org
To: stas.yakovlev-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, kvalo-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org,
	bkenward-s/n/eUQHGBpZroRs9YW3xA@public.gmane.org, linux-driver-h88ZbnxC6KDQT0dZR+AlfA@public.gmane.org,
	computersforpeace-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, m.chehab-Sze3O3UU22JBDgjK7y7TUQ@public.gmane.org,
	pawel-FA/gS7QP4orQT0dZR+AlfA@public.gmane.org, m.szyprowski-Sze3O3UU22JBDgjK7y7TUQ@public.gmane.org,
	kyungmin.park-Sze3O3UU22JBDgjK7y7TUQ@public.gmane.org, k.kozlowski-Sze3O3UU22JBDgjK7y7TUQ@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

I find that the developers often just specified the numeric value
when calling a macro which is defined with a parameter for access permission.
As we know, these numeric value for access permission have had the corresponding macro,
and that using macro can improve the robustness and readability of the code,
thus, I suggest replacing the numeric parameter with the macro.

Signed-off-by: Chuansheng Liu <chuansheng.liu-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
Signed-off-by: Baole Ni <baolex.ni-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
---
 drivers/net/wireless/intel/ipw2x00/ipw2100.c | 10 +++++-----
 1 file changed, 5 insertions(+), 5 deletions(-)

diff --git a/drivers/net/wireless/intel/ipw2x00/ipw2100.c b/drivers/net/wireless/intel/ipw2x00/ipw2100.c
index bfa542c..e94e000 100644
--- a/drivers/net/wireless/intel/ipw2x00/ipw2100.c
+++ b/drivers/net/wireless/intel/ipw2x00/ipw2100.c
@@ -197,11 +197,11 @@ static struct ipw2100_fw ipw2100_firmware;
 #endif
 
 #include <linux/moduleparam.h>
-module_param(debug, int, 0444);
-module_param_named(mode, network_mode, int, 0444);
-module_param(channel, int, 0444);
-module_param(associate, int, 0444);
-module_param(disable, int, 0444);
+module_param(debug, int, S_IRUSR | S_IRGRP | S_IROTH);
+module_param_named(mode, network_mode, int, S_IRUSR | S_IRGRP | S_IROTH);
+module_param(channel, int, S_IRUSR | S_IRGRP | S_IROTH);
+module_param(associate, int, S_IRUSR | S_IRGRP | S_IROTH);
+module_param(disable, int, S_IRUSR | S_IRGRP | S_IROTH);
 
 MODULE_PARM_DESC(debug, "debug level");
 MODULE_PARM_DESC(mode, "network mode (0=BSS,1=IBSS,2=Monitor)");
-- 
2.9.2

--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
