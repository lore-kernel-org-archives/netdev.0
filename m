From: Zhu Yi <yi.zhu@intel.com>
Subject: [PATCH] ipw2200: Fix compile error when CONFIG_IPW2200_DEBUG is not selected
Date: Tue, 22 Aug 2006 17:11:56 +0800
Message-ID: <20060822091154.GA14219@mail.intel.com>
Reply-To: yi.zhu@intel.com
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:35906 "EHLO
	orsmga102-1.jf.intel.com") by vger.kernel.org with ESMTP
	id S1751370AbWHVJNy (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 22 Aug 2006 05:13:54 -0400
To: netdev@vger.kernel.org, "John W. Linville" <linville@tuxdriver.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Zhu Yi <yi.zhu@intel.com>

---

 drivers/net/wireless/ipw2200.c |    4 ----
 1 files changed, 0 insertions(+), 4 deletions(-)

e2037ce8584be3c909339a6156235628fb82f26a
diff --git a/drivers/net/wireless/ipw2200.c b/drivers/net/wireless/ipw2200.c
index 750c25d..fa245f1 100644
--- a/drivers/net/wireless/ipw2200.c
+++ b/drivers/net/wireless/ipw2200.c
@@ -83,9 +83,7 @@ MODULE_AUTHOR(DRV_COPYRIGHT);
 MODULE_LICENSE("GPL");
 
 static int cmdlog = 0;
-#ifdef CONFIG_IPW2200_DEBUG
 static int debug = 0;
-#endif
 static int channel = 0;
 static int mode = 0;
 
@@ -11824,10 +11822,8 @@ MODULE_PARM_DESC(auto_create, "auto crea
 module_param(led, int, 0444);
 MODULE_PARM_DESC(led, "enable led control on some systems (default 0 off)\n");
 
-#ifdef CONFIG_IPW2200_DEBUG
 module_param(debug, int, 0444);
 MODULE_PARM_DESC(debug, "debug output mask");
-#endif
 
 module_param(channel, int, 0444);
 MODULE_PARM_DESC(channel, "channel to limit associate to (default 0 [ANY])");
-- 
1.2.6
