From: "John W. Linville" <linville@tuxdriver.com>
Subject: [PATCH] mac80211: fix debugfs tx power reduction output
Date: Mon, 11 Jun 2007 21:18:02 -0400
Message-ID: <20070612011802.GE20422@tuxdriver.com>
References: <20070612011616.GC20422@tuxdriver.com> <20070612011716.GD20422@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from ra.tuxdriver.com ([70.61.120.52]:4167 "EHLO ra.tuxdriver.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756839AbXFLByn (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 11 Jun 2007 21:54:43 -0400
Content-Disposition: inline
In-Reply-To: <20070612011716.GD20422@tuxdriver.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Johannes Berg <johannes@sipsolutions.net>

This patch fixes a typo in mac80211's debugfs.c.

Signed-off-by: Johannes Berg <johannes@sipsolutions.net>
Signed-off-by: John W. Linville <linville@tuxdriver.com>
---
 net/mac80211/debugfs.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/net/mac80211/debugfs.c b/net/mac80211/debugfs.c
index bb6c0fe..476c848 100644
--- a/net/mac80211/debugfs.c
+++ b/net/mac80211/debugfs.c
@@ -112,7 +112,7 @@ DEBUGFS_READONLY_FILE(wep_iv, 20, "%#06x",
 		      local->wep_iv & 0xffffff);
 DEBUGFS_READONLY_FILE(tx_power_reduction, 20, "%d.%d dBm",
 		      local->hw.conf.tx_power_reduction / 10,
-		      local->hw.conf.tx_power_reduction & 10);
+		      local->hw.conf.tx_power_reduction % 10);
 DEBUGFS_READONLY_FILE(rate_ctrl_alg, 100, "%s",
 		      local->rate_ctrl ? local->rate_ctrl->ops->name : "<unset>");
 
-- 
1.5.0.6

-- 
John W. Linville
linville@tuxdriver.com
