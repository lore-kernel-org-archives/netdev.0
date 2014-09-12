From: Larry Finger <Larry.Finger@lwfinger.net>
Subject: [PATCH] rtlwifi: btcoexist: avoid format string in printk
Date: Thu, 11 Sep 2014 19:02:10 -0500
Message-ID: <1410480130-11957-1-git-send-email-Larry.Finger@lwfinger.net>
Cc: linux-wireless@vger.kernel.org,
	Larry Finger <Larry.Finger@lwfinger.net>,
	netdev@vger.kernel.org, Kees Cook <keescook@chromium.org>
To: linville@tuxdriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f175.google.com ([209.85.214.175]:36071 "EHLO
	mail-ob0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751215AbaILACT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Sep 2014 20:02:19 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Recent changes to this driver inadvertently reverted the change made by Kees
Cook in commit 6437f51ec3.

Reported-by: Kees Cook <keescook@chromium.org>
Signed-off-by: Larry Finger <Larry.Finger@lwfinger.net>
Cc: Kees Cook <keescook@chromium.org>
---
 drivers/net/wireless/rtlwifi/btcoexist/halbtcoutsrc.h | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/wireless/rtlwifi/btcoexist/halbtcoutsrc.h b/drivers/net/wireless/rtlwifi/btcoexist/halbtcoutsrc.h
index 0d185e6..3cd2175 100644
--- a/drivers/net/wireless/rtlwifi/btcoexist/halbtcoutsrc.h
+++ b/drivers/net/wireless/rtlwifi/btcoexist/halbtcoutsrc.h
@@ -117,7 +117,7 @@ extern u32 btc_dbg_type[];
 #define		WIFI_P2P_GC_CONNECTED			BIT4
 
 #define	CL_SPRINTF	snprintf
-#define	CL_PRINTF	printk
+#define	CL_PRINTF(buf)	printk("%s", buf)
 
 #define	BTC_PRINT(dbgtype, dbgflag, printstr, ...)		\
 	do {							\
-- 
1.8.4.5
