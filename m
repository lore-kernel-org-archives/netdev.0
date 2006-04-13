From: Zhu Yi <yi.zhu@intel.com>
Subject: [PATCH 06/18] ipw2200: Do not continue loading the firmware if kmalloc fails
Date: Thu, 13 Apr 2006 17:19:50 +0800
Message-ID: <20060413091950.GA28741@mail.intel.com>
Reply-To: yi.zhu@intel.com
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <netdev-owner@vger.kernel.org>
Received: from fmr20.intel.com ([134.134.136.19]:63152 "EHLO
	orsfmr005.jf.intel.com") by vger.kernel.org with ESMTP
	id S964848AbWDMJ0x (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 13 Apr 2006 05:26:53 -0400
To: netdev@vger.kernel.org, "John W. Linville" <linville@tuxdriver.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Ingo Molnar <mingo@elte.hu>
Cc: "Zhu, Yi" <yi.zhu@intel.com>
Signed-off-by: Andrew Morton <akpm@osdl.org>

---

 drivers/net/wireless/ipw2200.c |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

bb9de6f2888b04991bc634e9700114d3b415cdcb
diff --git a/drivers/net/wireless/ipw2200.c b/drivers/net/wireless/ipw2200.c
index c38fb90..febee43 100644
--- a/drivers/net/wireless/ipw2200.c
+++ b/drivers/net/wireless/ipw2200.c
@@ -10666,6 +10666,7 @@ static int ipw_up(struct ipw_priv *priv)
 		if (priv->cmdlog == NULL) {
 			IPW_ERROR("Error allocating %d command log entries.\n",
 				  cmdlog);
+			return -ENOMEM;
 		} else {
 			memset(priv->cmdlog, 0, sizeof(*priv->cmdlog) * cmdlog);
 			priv->cmdlog_len = cmdlog;
-- 
1.2.6

