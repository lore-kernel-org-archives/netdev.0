From: Larry Finger <Larry.Finger@lwfinger.net>
Subject: [PATCH -4.2] rtlwifi: rtl8723be: Add module parameter for MSI interrupts
Date: Sun,  2 Aug 2015 13:24:13 -0500
Message-ID: <1438539853-29619-1-git-send-email-Larry.Finger@lwfinger.net>
Cc: linux-wireless@vger.kernel.org,
	Larry Finger <Larry.Finger@lwfinger.net>,
	netdev@vger.kernel.org, Stable <stable@vger.kernel.org>
To: kvalo@codeaurora.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f172.google.com ([209.85.214.172]:36639 "EHLO
	mail-ob0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751680AbbHBSY2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 2 Aug 2015 14:24:28 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The driver code allows for the disabling of MSI interrupts; however the
module_parm line was missed and the option fails to show with modinfo.

Signed-off-by: Larry Finger <Larry.Finger@lwfinger.net>
Cc: Stable <stable@vger.kernel.org> [3.15+]
---

Kalle,

This one-liner should be applied as soon as possible.

Thanks,

Larry
---
 drivers/net/wireless/rtlwifi/rtl8723be/sw.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/drivers/net/wireless/rtlwifi/rtl8723be/sw.c b/drivers/net/wireless/rtlwifi/rtl8723be/sw.c
index 1017f02..7bf88d9 100644
--- a/drivers/net/wireless/rtlwifi/rtl8723be/sw.c
+++ b/drivers/net/wireless/rtlwifi/rtl8723be/sw.c
@@ -385,6 +385,7 @@ module_param_named(debug, rtl8723be_mod_params.debug, int, 0444);
 module_param_named(ips, rtl8723be_mod_params.inactiveps, bool, 0444);
 module_param_named(swlps, rtl8723be_mod_params.swctrl_lps, bool, 0444);
 module_param_named(fwlps, rtl8723be_mod_params.fwctrl_lps, bool, 0444);
+module_param_named(msi, rtl8723be_mod_params.msi_support, bool, 0444);
 module_param_named(disable_watchdog, rtl8723be_mod_params.disable_watchdog,
 		   bool, 0444);
 MODULE_PARM_DESC(swenc, "Set to 1 for software crypto (default 0)\n");
-- 
2.1.4
