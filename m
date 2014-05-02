From: Masanari Iida <standby24x7-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: [PATCH] cfg80211/mac80211: Fix warning on make xmldocs caused by cfg80211.h
Date: Fri,  2 May 2014 23:39:57 +0900
Message-ID: <1399041597-27409-2-git-send-email-standby24x7@gmail.com>
References: <1399041597-27409-1-git-send-email-standby24x7@gmail.com>
Cc: Masanari Iida <standby24x7-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
To: luciano.coelho-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org, johannes.berg-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1399041597-27409-1-git-send-email-standby24x7-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Following error messages caused by wrong description.

Warning(include/net/cfg80211.h:461): No description found
for parameter 'nl80211_iftype'

Change "iftype" to "nl80211_iftype" fix the errors.

Signed-off-by: Masanari Iida <standby24x7-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
---
 include/net/cfg80211.h | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/include/net/cfg80211.h b/include/net/cfg80211.h
index 7eae46c..695c562 100644
--- a/include/net/cfg80211.h
+++ b/include/net/cfg80211.h
@@ -452,7 +452,7 @@ bool cfg80211_chandef_usable(struct wiphy *wiphy,
  * cfg80211_chandef_dfs_required - checks if radar detection is required
  * @wiphy: the wiphy to validate against
  * @chandef: the channel definition to check
- * @iftype: the interface type as specified in &enum nl80211_iftype
+ * @nl80211_iftype: the interface type as specified in &enum nl80211_iftype
  * Returns:
  *	1 if radar detection is required, 0 if it is not, < 0 on error
  */
-- 
2.0.0.rc1.15.g7e76a2f

--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
