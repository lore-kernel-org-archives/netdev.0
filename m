From: Larry Finger <Larry.Finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org>
Subject: [PATCH 5/6] rtlwifi: rtl8192de: Fix W=1 build warnings
Date: Fri,  1 Feb 2013 10:40:26 -0600
Message-ID: <1359736827-30977-6-git-send-email-Larry.Finger@lwfinger.net>
References: <1359736827-30977-1-git-send-email-Larry.Finger@lwfinger.net>
Cc: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Larry Finger <Larry.Finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org>,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1359736827-30977-1-git-send-email-Larry.Finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

when this driver is built with "make W=1", the following warning is printed:

drivers/net/wireless/rtlwifi/rtl8192de/dm.c:1058:5: warning: comparison is always false due to limited range of data type [-Wtype-limits]

Signed-off-by: Larry Finger <Larry.Finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org>
---
 drivers/net/wireless/rtlwifi/rtl8192de/dm.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/wireless/rtlwifi/rtl8192de/dm.c b/drivers/net/wireless/rtlwifi/rtl8192de/dm.c
index fd8df23..5251fb8 100644
--- a/drivers/net/wireless/rtlwifi/rtl8192de/dm.c
+++ b/drivers/net/wireless/rtlwifi/rtl8192de/dm.c
@@ -841,9 +841,9 @@ static void rtl92d_dm_txpower_tracking_callback_thermalmeter(
 	long ele_a = 0, ele_d, temp_cck, val_x, value32;
 	long val_y, ele_c = 0;
 	u8 ofdm_index[2];
-	u8 cck_index = 0;
+	s8 cck_index = 0;
 	u8 ofdm_index_old[2];
-	u8 cck_index_old = 0;
+	s8 cck_index_old = 0;
 	u8 index;
 	int i;
 	bool is2t = IS_92D_SINGLEPHY(rtlhal->version);
-- 
1.8.1

--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
