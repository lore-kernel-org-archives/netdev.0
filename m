From: Julia Lawall <julia@diku.dk>
Subject: [PATCH 14/16] drivers/net/wireless/iwlwifi: remove exceptional & on
 function name
Date: Wed, 18 Nov 2009 19:25:25 +0100 (CET)
Message-ID: <Pine.LNX.4.64.0911181924510.20943@ask.diku.dk>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
To: Zhu Yi <yi.zhu@intel.com>,
	Reinette Chatre <reinette.chatre@intel.com>,
	Intel Linux Wireless <ilw@linux.intel.com>,
	"John W. Linville" <linville@tuxdriver.com>,
	linux-wireless@vger.k
Return-path: <netdev-owner@vger.kernel.org>
Received: from mgw2.diku.dk ([130.225.96.92]:56445 "EHLO mgw2.diku.dk"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932262AbZKRSZX (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 18 Nov 2009 13:25:23 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Julia Lawall <julia@diku.dk>

In this file, function names are otherwise used as pointers without &.

A simplified version of the semantic patch that makes this change is as
follows: (http://coccinelle.lip6.fr/)

// <smpl>
@r@
identifier f;
@@

f(...) { ... }

@@
identifier r.f;
@@

- &f
+ f
// </smpl>

Signed-off-by: Julia Lawall <julia@diku.dk>

---
 drivers/net/wireless/iwlwifi/iwl-3945-rs.c     |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/wireless/iwlwifi/iwl-3945-rs.c b/drivers/net/wireless/iwlwifi/iwl-3945-rs.c
index dc81e19..d4b4988 100644
--- a/drivers/net/wireless/iwlwifi/iwl-3945-rs.c
+++ b/drivers/net/wireless/iwlwifi/iwl-3945-rs.c
@@ -355,7 +355,7 @@ static void rs_rate_init(void *priv_r, struct ieee80211_supported_band *sband,
 
 	init_timer(&rs_sta->rate_scale_flush);
 	rs_sta->rate_scale_flush.data = (unsigned long)rs_sta;
-	rs_sta->rate_scale_flush.function = &iwl3945_bg_rate_scale_flush;
+	rs_sta->rate_scale_flush.function = iwl3945_bg_rate_scale_flush;
 
 	for (i = 0; i < IWL_RATE_COUNT_3945; i++)
 		iwl3945_clear_window(&rs_sta->win[i]);
