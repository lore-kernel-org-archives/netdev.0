From: Larry Finger <Larry.Finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org>
Subject: [PATCH 1/6] rtlwifi: Change logging level for key change
Date: Fri, 23 Jan 2015 11:10:39 -0600
Message-ID: <1422033044-7461-2-git-send-email-Larry.Finger@lwfinger.net>
References: <1422033044-7461-1-git-send-email-Larry.Finger@lwfinger.net>
Cc: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Larry Finger <Larry.Finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org>,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: kvalo-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1422033044-7461-1-git-send-email-Larry.Finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

A recent change in key handling included logging of these changes for
all debug levels. Such key changes should only be logged when a high
level of debugging is enabled.

Signed-off-by: Larry Finger <Larry.Finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org>
---
 drivers/net/wireless/rtlwifi/cam.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/wireless/rtlwifi/cam.c b/drivers/net/wireless/rtlwifi/cam.c
index 3ef870d..6e64792 100644
--- a/drivers/net/wireless/rtlwifi/cam.c
+++ b/drivers/net/wireless/rtlwifi/cam.c
@@ -406,7 +406,7 @@ u8 rtl_cam_get_free_entry(struct ieee80211_hw *hw, struct ieee80211_sta *sta,
 		}
 	}
 	if (found) {
-		RT_TRACE(rtlpriv, COMP_SEC, DBG_EMERG,
+		RT_TRACE(rtlpriv, COMP_SEC, DBG_DMESG,
 			 "key_index=%d,cam_bitmap: 0x%x entry_idx=%d\n",
 			  key_index, rtlpriv->sec.cam_bitmap, entry_idx);
 		return entry_idx;
-- 
2.1.2

--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
