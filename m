From: Zhu Yi <yi.zhu@intel.com>
Subject: [PATCH] ipw2100: wraps the debug module param within #ifdefs
Date: Thu, 13 Apr 2006 17:14:23 +0800
Message-ID: <20060413091423.GA28623@mail.intel.com>
Reply-To: yi.zhu@intel.com
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <netdev-owner@vger.kernel.org>
Received: from fmr20.intel.com ([134.134.136.19]:22960 "EHLO
	orsfmr005.jf.intel.com") by vger.kernel.org with ESMTP
	id S1751175AbWDMJVa (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 13 Apr 2006 05:21:30 -0400
To: netdev@vger.kernel.org, "John W. Linville" <linville@tuxdriver.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Henrik Brix Andersen <brix@gentoo.org>
Signed-off-by: Zhu Yi <yi.zhu@intel.com>

---

 drivers/net/wireless/ipw2100.c |    6 ++++++
 1 files changed, 6 insertions(+), 0 deletions(-)

e78cfdab91a809722be99c06574d2e0a60467644
diff --git a/drivers/net/wireless/ipw2100.c b/drivers/net/wireless/ipw2100.c
index 72335c8..2cd32a4 100644
--- a/drivers/net/wireless/ipw2100.c
+++ b/drivers/net/wireless/ipw2100.c
@@ -184,7 +184,9 @@ MODULE_VERSION(DRV_VERSION);
 MODULE_AUTHOR(DRV_COPYRIGHT);
 MODULE_LICENSE("GPL");
 
+#ifdef CONFIG_IPW2100_DEBUG
 static int debug = 0;
+#endif
 static int mode = 0;
 static int channel = 0;
 static int associate = 1;
@@ -194,13 +196,17 @@ static struct ipw2100_fw ipw2100_firmwar
 #endif
 
 #include <linux/moduleparam.h>
+#ifdef CONFIG_IPW2100_DEBUG
 module_param(debug, int, 0444);
+#endif
 module_param(mode, int, 0444);
 module_param(channel, int, 0444);
 module_param(associate, int, 0444);
 module_param(disable, int, 0444);
 
+#ifdef CONFIG_IPW2100_DEBUG
 MODULE_PARM_DESC(debug, "debug level");
+#endif
 MODULE_PARM_DESC(mode, "network mode (0=BSS,1=IBSS,2=Monitor)");
 MODULE_PARM_DESC(channel, "channel");
 MODULE_PARM_DESC(associate, "auto associate when scanning (default on)");
-- 
1.2.6

