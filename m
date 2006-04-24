From: Alex Davis <alex14641@yahoo.com>
Subject: [PATCH] compile error in ieee80211_ioctl.c
Date: Sun, 23 Apr 2006 17:26:39 -0700 (PDT)
Message-ID: <20060424002639.54669.qmail@web50214.mail.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Return-path: <netdev-owner@vger.kernel.org>
Received: from web50214.mail.yahoo.com ([206.190.39.189]:13184 "HELO
	web50214.mail.yahoo.com") by vger.kernel.org with SMTP
	id S1750804AbWDXA0k (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 23 Apr 2006 20:26:40 -0400
To: linville@tuxdriver.com, netdev@vger.kernel.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello:

I cloned git://git.kernel.org/pub/scm/linux/kernel/git/linville/wireless-dev.git
last night and got compile errors while compiling net/d80211/ieee80211_ioctl.c
into a module. This patch fixes it.

Signed-off-by: Alex Davis <alex14641@yahoo.com>

diff --git a/net/d80211/ieee80211_ioctl.c b/net/d80211/ieee80211_ioctl.c
index 42a7abe..4949e52 100644
--- a/net/d80211/ieee80211_ioctl.c
+++ b/net/d80211/ieee80211_ioctl.c
@@ -30,7 +30,7 @@ #include "aes_ccm.h"
 
 
 static int ieee80211_regdom = 0x10; /* FCC */
-MODULE_PARM(ieee80211_regdom, "i");
+module_param(ieee80211_regdom, int, 0x10);
 MODULE_PARM_DESC(ieee80211_regdom, "IEEE 802.11 regulatory domain; 64=MKK");
 
 /*
@@ -40,7 +40,7 @@ MODULE_PARM_DESC(ieee80211_regdom, "IEEE
  * module.
  */
 static int ieee80211_japan_5ghz /* = 0 */;
-MODULE_PARM(ieee80211_japan_5ghz, "i");
+module_param(ieee80211_japan_5ghz, int, 0);
 MODULE_PARM_DESC(ieee80211_japan_5ghz, "Vendor-updated firmware for 5 GHz");
 


I code, therefore I am

__________________________________________________
Do You Yahoo!?
Tired of spam?  Yahoo! Mail has the best spam protection around 
http://mail.yahoo.com 
