From: Larry Finger <Larry.Finger@lwfinger.net>
Subject: [PATCH 02/11] rtlwifi: rtl8723be: Improve modinfo output
Date: Fri,  2 Jan 2015 10:58:19 -0600
Message-ID: <1420217908-1382-3-git-send-email-Larry.Finger@lwfinger.net>
References: <1420217908-1382-1-git-send-email-Larry.Finger@lwfinger.net>
Cc: linux-wireless@vger.kernel.org,
	Larry Finger <Larry.Finger@lwfinger.net>,
	netdev@vger.kernel.org
To: kvalo@codeaurora.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f170.google.com ([209.85.214.170]:38765 "EHLO
	mail-ob0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752172AbbABQ6g (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 2 Jan 2015 11:58:36 -0500
In-Reply-To: <1420217908-1382-1-git-send-email-Larry.Finger@lwfinger.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The description of the power-save variables for this driver is not as
clear as for the others. The wording is changed to match the others.

Signed-off-by: Larry Finger <Larry.Finger@lwfinger.net>
---
 drivers/net/wireless/rtlwifi/rtl8723be/sw.c | 11 ++++++-----
 1 file changed, 6 insertions(+), 5 deletions(-)

diff --git a/drivers/net/wireless/rtlwifi/rtl8723be/sw.c b/drivers/net/wireless/rtlwifi/rtl8723be/sw.c
index 223eb42..52a6d90 100644
--- a/drivers/net/wireless/rtlwifi/rtl8723be/sw.c
+++ b/drivers/net/wireless/rtlwifi/rtl8723be/sw.c
@@ -387,12 +387,13 @@ module_param_named(swlps, rtl8723be_mod_params.swctrl_lps, bool, 0444);
 module_param_named(fwlps, rtl8723be_mod_params.fwctrl_lps, bool, 0444);
 module_param_named(disable_watchdog, rtl8723be_mod_params.disable_watchdog,
 		   bool, 0444);
-MODULE_PARM_DESC(swenc, "using hardware crypto (default 0 [hardware])\n");
-MODULE_PARM_DESC(ips, "using no link power save (default 1 is open)\n");
-MODULE_PARM_DESC(fwlps, "using linked fw control power save (default 1 is open)\n");
-MODULE_PARM_DESC(msi, "Set to 1 to use MSI interrupts mode (default 0)\n");
+MODULE_PARM_DESC(swenc, "Set to 1 for software crypto (default 0)\n");
+MODULE_PARM_DESC(ips, "Set to 0 to not use link power save (default 1)\n");
+MODULE_PARM_DESC(swlps, "Set to 1 to use SW control power save (default 0)\n");
+MODULE_PARM_DESC(fwlps, "Set to 1 to use FW control power save (default 1)\n");
 MODULE_PARM_DESC(debug, "Set debug level (0-5) (default 0)");
-MODULE_PARM_DESC(disable_watchdog, "Set to 1 to disable the watchdog (default 0)\n");
+MODULE_PARM_DESC(disable_watchdog,
+		 "Set to 1 to disable the watchdog (default 0)\n");
 
 static SIMPLE_DEV_PM_OPS(rtlwifi_pm_ops, rtl_pci_suspend, rtl_pci_resume);
 
-- 
2.1.2
