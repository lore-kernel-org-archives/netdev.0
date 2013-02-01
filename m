From: Larry Finger <Larry.Finger@lwfinger.net>
Subject: [PATCH 1/6] rtlwifi: Fix many compile warnings when using W=1
Date: Fri,  1 Feb 2013 10:40:22 -0600
Message-ID: <1359736827-30977-2-git-send-email-Larry.Finger@lwfinger.net>
References: <1359736827-30977-1-git-send-email-Larry.Finger@lwfinger.net>
Cc: linux-wireless@vger.kernel.org,
	Larry Finger <Larry.Finger@lwfinger.net>,
	netdev@vger.kernel.org
To: linville@tuxdriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oa0-f54.google.com ([209.85.219.54]:56278 "EHLO
	mail-oa0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757038Ab3BAQkp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 1 Feb 2013 11:40:45 -0500
In-Reply-To: <1359736827-30977-1-git-send-email-Larry.Finger@lwfinger.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Many warnings like the following arise from a build with W=1 on the
make line:

warning: comparison of unsigned expression >= 0 is always true [-Wtype-limits]

Changing the overall debug level storage from unsigned to signed fixes these.

Signed-off-by: Larry Finger <Larry.Finger@lwfinger.net>
---
 drivers/net/wireless/rtlwifi/wifi.h | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/wireless/rtlwifi/wifi.h b/drivers/net/wireless/rtlwifi/wifi.h
index 21a5f4f..f13258a 100644
--- a/drivers/net/wireless/rtlwifi/wifi.h
+++ b/drivers/net/wireless/rtlwifi/wifi.h
@@ -1702,7 +1702,7 @@ struct rtl_works {
 
 struct rtl_debug {
 	u32 dbgp_type[DBGP_TYPE_MAX];
-	u32 global_debuglevel;
+	int global_debuglevel;
 	u64 global_debugcomponents;
 
 	/* add for proc debug */
-- 
1.8.1
