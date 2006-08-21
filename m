From: Zhu Yi <yi.zhu@intel.com>
Subject: [PATCH 2/7] ieee80211: remove ieee80211_tx() is_queue_full warning
Date: Mon, 21 Aug 2006 11:32:47 +0800
Message-ID: <20060821033247.GA4775@mail.intel.com>
Reply-To: yi.zhu@intel.com
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:22680 "EHLO
	orsmga101-1.jf.intel.com") by vger.kernel.org with ESMTP
	id S932118AbWHUDeo (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 20 Aug 2006 23:34:44 -0400
To: netdev@vger.kernel.org, "John W. Linville" <linville@tuxdriver.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Zhu Yi <yi.zhu@intel.com>

---

 net/ieee80211/ieee80211_tx.c |    7 -------
 1 files changed, 0 insertions(+), 7 deletions(-)

2890239696cb57c3fbf6b948042cfeac70de561e
diff --git a/net/ieee80211/ieee80211_tx.c b/net/ieee80211/ieee80211_tx.c
index f2e6131..ae25449 100644
--- a/net/ieee80211/ieee80211_tx.c
+++ b/net/ieee80211/ieee80211_tx.c
@@ -532,13 +532,6 @@ int ieee80211_xmit(struct sk_buff *skb, 
 			return 0;
 		}
 
-		if (ret == NETDEV_TX_BUSY) {
-			printk(KERN_ERR "%s: NETDEV_TX_BUSY returned; "
-			       "driver should report queue full via "
-			       "ieee_device->is_queue_full.\n",
-			       ieee->dev->name);
-		}
-
 		ieee80211_txb_free(txb);
 	}
 
-- 
1.2.6
