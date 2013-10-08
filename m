From: djduanjiong-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org
Subject: [PATCH] mac80211: Use ERR_CAST inlined function instead of ERR_PTR(PTR_ERR(...))
Date: Mon,  7 Oct 2013 17:09:13 -0700
Message-ID: <1381190953-6362-1-git-send-email-duanj.fnst@cn.fujitsu.com>
Cc: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Duan Jiong <duanj.fnst-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
To: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>,
	"John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>,
	"David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Duan Jiong <duanj.fnst-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>

Signed-off-by: Duan Jiong <duanj.fnst-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
---
 net/mac80211/key.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/net/mac80211/key.c b/net/mac80211/key.c
index 620677e..3e51dd7 100644
--- a/net/mac80211/key.c
+++ b/net/mac80211/key.c
@@ -879,7 +879,7 @@ ieee80211_gtk_rekey_add(struct ieee80211_vif *vif,
 				  keyconf->keylen, keyconf->key,
 				  0, NULL);
 	if (IS_ERR(key))
-		return ERR_PTR(PTR_ERR(key));
+		return ERR_CAST(key);
 
 	if (sdata->u.mgd.mfp != IEEE80211_MFP_DISABLED)
 		key->conf.flags |= IEEE80211_KEY_FLAG_RX_MGMT;
-- 
1.7.7.6

--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
