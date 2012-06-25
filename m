From: Alexandre Pereira da Silva <aletes.xgr@gmail.com>
Subject: [PATCH] mac80211: fix build warning
Date: Mon, 25 Jun 2012 12:19:10 -0300
Message-ID: <1340637550-12669-1-git-send-email-aletes.xgr@gmail.com>
Cc: Alexandre Pereira da Silva <aletes.xgr@gmail.com>,
	"John W. Linville" <linville@tuxdriver.com>,
	Johannes Berg <johannes@sipsolutions.net>,
	"David S. Miller" <davem@davemloft.net>,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: unlisted-recipients:; (no To-header on input)
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Fix:
net/mac80211/mlme.c: In function 'ieee80211_prep_connection':
net/mac80211/mlme.c:3035:19: warning: 'sta' may be used uninitialized in
this function

Initialize sta to NULL

Signed-off-by: Alexandre Pereira da Silva <aletes.xgr@gmail.com>
---
 net/mac80211/mlme.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/mac80211/mlme.c b/net/mac80211/mlme.c
index 91d84cc..cfe6b43 100644
--- a/net/mac80211/mlme.c
+++ b/net/mac80211/mlme.c
@@ -3032,7 +3032,7 @@ static int ieee80211_prep_connection(struct ieee80211_sub_if_data *sdata,
 	struct ieee80211_local *local = sdata->local;
 	struct ieee80211_if_managed *ifmgd = &sdata->u.mgd;
 	struct ieee80211_bss *bss = (void *)cbss->priv;
-	struct sta_info *sta;
+	struct sta_info *sta = NULL;
 	bool have_sta = false;
 	int err;
 	int ht_cfreq;
-- 
1.7.10
