From: Larry Finger <Larry.Finger@lwfinger.net>
Subject: [PATCH V2 1/6] rtlwifi: Change logging level for key change
Date: Mon, 26 Jan 2015 14:42:09 -0600
Message-ID: <1422304934-9239-2-git-send-email-Larry.Finger@lwfinger.net>
References: <1422304934-9239-1-git-send-email-Larry.Finger@lwfinger.net>
Cc: linux-wireless@vger.kernel.org,
	Larry Finger <Larry.Finger@lwfinger.net>,
	netdev@vger.kernel.org
To: kvalo@codeaurora.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f175.google.com ([209.85.214.175]:34980 "EHLO
	mail-ob0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751517AbbAZUmd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 26 Jan 2015 15:42:33 -0500
In-Reply-To: <1422304934-9239-1-git-send-email-Larry.Finger@lwfinger.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

A recent change in key handling included logging of these changes for
all debug levels. Such key changes should only be logged when a high
level of debugging is enabled.

Signed-off-by: Larry Finger <Larry.Finger@lwfinger.net>
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
