From: Baole Ni <baolex.ni-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
Subject: [PATCH 0775/1285] Replace numeric parameter like 0444 with macro
Date: Tue,  2 Aug 2016 19:45:12 +0800
Message-ID: <20160802114512.1368-1-baolex.ni@intel.com>
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
 drivers/net/wireless/intel/ipw2x00/ipw2200.c | 38 ++++++++++++++--------------
 1 file changed, 19 insertions(+), 19 deletions(-)

diff --git a/drivers/net/wireless/intel/ipw2x00/ipw2200.c b/drivers/net/wireless/intel/ipw2x00/ipw2200.c
index 5adb7ce..f02759e 100644
--- a/drivers/net/wireless/intel/ipw2x00/ipw2200.c
+++ b/drivers/net/wireless/intel/ipw2x00/ipw2200.c
@@ -11993,68 +11993,68 @@ static void __exit ipw_exit(void)
 	pci_unregister_driver(&ipw_driver);
 }
 
-module_param(disable, int, 0444);
+module_param(disable, int, S_IRUSR | S_IRGRP | S_IROTH);
 MODULE_PARM_DESC(disable, "manually disable the radio (default 0 [radio on])");
 
-module_param(associate, int, 0444);
+module_param(associate, int, S_IRUSR | S_IRGRP | S_IROTH);
 MODULE_PARM_DESC(associate, "auto associate when scanning (default off)");
 
-module_param(auto_create, int, 0444);
+module_param(auto_create, int, S_IRUSR | S_IRGRP | S_IROTH);
 MODULE_PARM_DESC(auto_create, "auto create adhoc network (default on)");
 
-module_param_named(led, led_support, int, 0444);
+module_param_named(led, led_support, int, S_IRUSR | S_IRGRP | S_IROTH);
 MODULE_PARM_DESC(led, "enable led control on some systems (default 1 on)");
 
-module_param(debug, int, 0444);
+module_param(debug, int, S_IRUSR | S_IRGRP | S_IROTH);
 MODULE_PARM_DESC(debug, "debug output mask");
 
-module_param_named(channel, default_channel, int, 0444);
+module_param_named(channel, default_channel, int, S_IRUSR | S_IRGRP | S_IROTH);
 MODULE_PARM_DESC(channel, "channel to limit associate to (default 0 [ANY])");
 
 #ifdef CONFIG_IPW2200_PROMISCUOUS
-module_param(rtap_iface, int, 0444);
+module_param(rtap_iface, int, S_IRUSR | S_IRGRP | S_IROTH);
 MODULE_PARM_DESC(rtap_iface, "create the rtap interface (1 - create, default 0)");
 #endif
 
 #ifdef CONFIG_IPW2200_QOS
-module_param(qos_enable, int, 0444);
+module_param(qos_enable, int, S_IRUSR | S_IRGRP | S_IROTH);
 MODULE_PARM_DESC(qos_enable, "enable all QoS functionalitis");
 
-module_param(qos_burst_enable, int, 0444);
+module_param(qos_burst_enable, int, S_IRUSR | S_IRGRP | S_IROTH);
 MODULE_PARM_DESC(qos_burst_enable, "enable QoS burst mode");
 
-module_param(qos_no_ack_mask, int, 0444);
+module_param(qos_no_ack_mask, int, S_IRUSR | S_IRGRP | S_IROTH);
 MODULE_PARM_DESC(qos_no_ack_mask, "mask Tx_Queue to no ack");
 
-module_param(burst_duration_CCK, int, 0444);
+module_param(burst_duration_CCK, int, S_IRUSR | S_IRGRP | S_IROTH);
 MODULE_PARM_DESC(burst_duration_CCK, "set CCK burst value");
 
-module_param(burst_duration_OFDM, int, 0444);
+module_param(burst_duration_OFDM, int, S_IRUSR | S_IRGRP | S_IROTH);
 MODULE_PARM_DESC(burst_duration_OFDM, "set OFDM burst value");
 #endif				/* CONFIG_IPW2200_QOS */
 
 #ifdef CONFIG_IPW2200_MONITOR
-module_param_named(mode, network_mode, int, 0444);
+module_param_named(mode, network_mode, int, S_IRUSR | S_IRGRP | S_IROTH);
 MODULE_PARM_DESC(mode, "network mode (0=BSS,1=IBSS,2=Monitor)");
 #else
-module_param_named(mode, network_mode, int, 0444);
+module_param_named(mode, network_mode, int, S_IRUSR | S_IRGRP | S_IROTH);
 MODULE_PARM_DESC(mode, "network mode (0=BSS,1=IBSS)");
 #endif
 
-module_param(bt_coexist, int, 0444);
+module_param(bt_coexist, int, S_IRUSR | S_IRGRP | S_IROTH);
 MODULE_PARM_DESC(bt_coexist, "enable bluetooth coexistence (default off)");
 
-module_param(hwcrypto, int, 0444);
+module_param(hwcrypto, int, S_IRUSR | S_IRGRP | S_IROTH);
 MODULE_PARM_DESC(hwcrypto, "enable hardware crypto (default off)");
 
-module_param(cmdlog, int, 0444);
+module_param(cmdlog, int, S_IRUSR | S_IRGRP | S_IROTH);
 MODULE_PARM_DESC(cmdlog,
 		 "allocate a ring buffer for logging firmware commands");
 
-module_param(roaming, int, 0444);
+module_param(roaming, int, S_IRUSR | S_IRGRP | S_IROTH);
 MODULE_PARM_DESC(roaming, "enable roaming support (default on)");
 
-module_param(antenna, int, 0444);
+module_param(antenna, int, S_IRUSR | S_IRGRP | S_IROTH);
 MODULE_PARM_DESC(antenna, "select antenna 1=Main, 3=Aux, default 0 [both], 2=slow_diversity (choose the one with lower background noise)");
 
 module_exit(ipw_exit);
-- 
2.9.2

--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
