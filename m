From: Zhu Yi <yi.zhu@intel.com>
Subject: [PATCH 05/18] ipw2200: fix compile warning when !CONFIG_IPW2200_DEBUG
Date: Thu, 13 Apr 2006 17:19:44 +0800
Message-ID: <20060413091944.GA28734@mail.intel.com>
Reply-To: yi.zhu@intel.com
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <netdev-owner@vger.kernel.org>
Received: from fmr17.intel.com ([134.134.136.16]:22698 "EHLO
	orsfmr002.jf.intel.com") by vger.kernel.org with ESMTP
	id S964840AbWDMJ0t (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 13 Apr 2006 05:26:49 -0400
To: netdev@vger.kernel.org, "John W. Linville" <linville@tuxdriver.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Zhu Yi <yi.zhu@intel.com>

---

 drivers/net/wireless/ipw2200.c |    2 ++
 1 files changed, 2 insertions(+), 0 deletions(-)

4c418f1f7845ec9d78fe4f3a7346416c13662ace
diff --git a/drivers/net/wireless/ipw2200.c b/drivers/net/wireless/ipw2200.c
index 6b8c47b..c38fb90 100644
--- a/drivers/net/wireless/ipw2200.c
+++ b/drivers/net/wireless/ipw2200.c
@@ -46,7 +46,9 @@ MODULE_AUTHOR(DRV_COPYRIGHT);
 MODULE_LICENSE("GPL");
 
 static int cmdlog = 0;
+#ifdef CONFIG_IPW2200_DEBUG
 static int debug = 0;
+#endif
 static int channel = 0;
 static int mode = 0;
 
-- 
1.2.6

