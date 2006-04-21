From: Jiri Benc <jbenc@suse.cz>
Subject: [PATCH 1/17] d80211: Replace MODULE_PARM with module_param
Date: Fri, 21 Apr 2006 22:11:32 +0200 (CEST)
Message-ID: <20060421201132.22B92482C1@silver.suse.cz>
References: <20060421220951.205579000.midnight@suse.cz>
Cc: "John W. Linville" <linville@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from styx.suse.cz ([82.119.242.94]:10119 "EHLO silver.suse.cz")
	by vger.kernel.org with ESMTP id S932400AbWDUULF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 Apr 2006 16:11:05 -0400
To: netdev@vger.kernel.org
In-Reply-To: <20060421220951.205579000.midnight@suse.cz>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Jouni Malinen <jkmaline@cc.hut.fi>

MODULE_PARM macro was removed and this broke net/d80211 build. Fix
this by using module_param instead of MODULE_PARM.

Signed-off-by: Jouni Malinen <jkmaline@cc.hut.fi>
Signed-off-by: Jiri Benc <jbenc@suse.cz>

---

 net/d80211/ieee80211_ioctl.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

d0d54060410447c5eb354886ac0ae9cff73a4b2c
diff --git a/net/d80211/ieee80211_ioctl.c b/net/d80211/ieee80211_ioctl.c
index 42a7abe..987f761 100644
--- a/net/d80211/ieee80211_ioctl.c
+++ b/net/d80211/ieee80211_ioctl.c
@@ -30,7 +30,7 @@ #include "aes_ccm.h"
 
 
 static int ieee80211_regdom = 0x10; /* FCC */
-MODULE_PARM(ieee80211_regdom, "i");
+module_param(ieee80211_regdom, int, 0444);
 MODULE_PARM_DESC(ieee80211_regdom, "IEEE 802.11 regulatory domain; 64=MKK");
 
 /*
@@ -40,7 +40,7 @@ MODULE_PARM_DESC(ieee80211_regdom, "IEEE
  * module.
  */
 static int ieee80211_japan_5ghz /* = 0 */;
-MODULE_PARM(ieee80211_japan_5ghz, "i");
+module_param(ieee80211_japan_5ghz, int, 0444);
 MODULE_PARM_DESC(ieee80211_japan_5ghz, "Vendor-updated firmware for 5 GHz");
 
 
-- 
1.3.0

