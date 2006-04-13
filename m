From: Zhu Yi <yi.zhu@intel.com>
Subject: [PATCH 4/6] ieee80211: remove unnecessary CONFIG_WIRELESS_EXT checking
Date: Thu, 13 Apr 2006 17:17:35 +0800
Message-ID: <20060413091735.GA28664@mail.intel.com>
Reply-To: yi.zhu@intel.com
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <netdev-owner@vger.kernel.org>
Received: from fmr19.intel.com ([134.134.136.18]:7629 "EHLO
	orsfmr004.jf.intel.com") by vger.kernel.org with ESMTP
	id S964834AbWDMJYk (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 13 Apr 2006 05:24:40 -0400
To: netdev@vger.kernel.org, "John W. Linville" <linville@tuxdriver.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Zhu Yi <yi.zhu@intel.com>

---

 net/ieee80211/ieee80211_rx.c |    2 --
 1 files changed, 0 insertions(+), 2 deletions(-)

06f3e8b703c93ff8dbadf005878850fcd3393e5f
diff --git a/net/ieee80211/ieee80211_rx.c b/net/ieee80211/ieee80211_rx.c
index 604b7b0..0d18742 100644
--- a/net/ieee80211/ieee80211_rx.c
+++ b/net/ieee80211/ieee80211_rx.c
@@ -369,7 +369,6 @@ int ieee80211_rx(struct ieee80211_device
 
 	/* Put this code here so that we avoid duplicating it in all
 	 * Rx paths. - Jean II */
-#ifdef CONFIG_WIRELESS_EXT
 #ifdef IW_WIRELESS_SPY		/* defined in iw_handler.h */
 	/* If spy monitoring on */
 	if (ieee->spy_data.spy_number > 0) {
@@ -398,7 +397,6 @@ int ieee80211_rx(struct ieee80211_device
 		wireless_spy_update(ieee->dev, hdr->addr2, &wstats);
 	}
 #endif				/* IW_WIRELESS_SPY */
-#endif				/* CONFIG_WIRELESS_EXT */
 
 #ifdef NOT_YET
 	hostap_update_rx_stats(local->ap, hdr, rx_stats);
-- 
1.2.6

