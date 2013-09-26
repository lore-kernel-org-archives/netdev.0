From: Larry Finger <Larry.Finger@lwfinger.net>
Subject: [PATCH 2/7] rtlwifi: rtl8192cu: Convert to use new rtl_phy_scan_operation_backup() routine
Date: Thu, 26 Sep 2013 13:25:28 -0500
Message-ID: <1380219933-16784-3-git-send-email-Larry.Finger@lwfinger.net>
References: <1380219933-16784-1-git-send-email-Larry.Finger@lwfinger.net>
Cc: linux-wireless@vger.kernel.org,
	Larry Finger <Larry.Finger@lwfinger.net>,
	netdev@vger.kernel.org
To: linville@tuxdriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oa0-f45.google.com ([209.85.219.45]:63123 "EHLO
	mail-oa0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753503Ab3IZS0E (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Sep 2013 14:26:04 -0400
In-Reply-To: <1380219933-16784-1-git-send-email-Larry.Finger@lwfinger.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Now that the routine exists in driver rtlwifi, convert rtl8192cu to use it.

Signed-off-by: Larry Finger <Larry.Finger@lwfinger.net>
---
 drivers/net/wireless/rtlwifi/rtl8192cu/sw.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/drivers/net/wireless/rtlwifi/rtl8192cu/sw.c b/drivers/net/wireless/rtlwifi/rtl8192cu/sw.c
index 2bd5985..9936de7 100644
--- a/drivers/net/wireless/rtlwifi/rtl8192cu/sw.c
+++ b/drivers/net/wireless/rtlwifi/rtl8192cu/sw.c
@@ -31,6 +31,7 @@
 #include "../core.h"
 #include "../usb.h"
 #include "../efuse.h"
+#include "../base.h"
 #include "reg.h"
 #include "def.h"
 #include "phy.h"
@@ -117,7 +118,7 @@ static struct rtl_hal_ops rtl8192cu_hal_ops = {
 	.set_bw_mode = rtl92c_phy_set_bw_mode,
 	.switch_channel = rtl92c_phy_sw_chnl,
 	.dm_watchdog = rtl92c_dm_watchdog,
-	.scan_operation_backup = rtl92c_phy_scan_operation_backup,
+	.scan_operation_backup = rtl_phy_scan_operation_backup,
 	.set_rf_power_state = rtl92cu_phy_set_rf_power_state,
 	.led_control = rtl92cu_led_control,
 	.enable_hw_sec = rtl92cu_enable_hw_security_config,
-- 
1.8.1.4
