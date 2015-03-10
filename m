From: Florian Westphal <fw-HFFVJYpyMKqzQB+pC5nmwQ@public.gmane.org>
Subject: [PATCH next] ath9k: make ath_frame_info fit into reduced-size rate_driver_data
Date: Tue, 10 Mar 2015 15:44:22 +0100
Message-ID: <1425998662-28401-1-git-send-email-fw@strlen.de>
Cc: ath9k-devel-A+ZNKFmMK5xy9aJCnZT0Uw@public.gmane.org, ath9k-devel-xDcbHBWguxHbcTqmT+pZeQ@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Florian Westphal <fw-HFFVJYpyMKqzQB+pC5nmwQ@public.gmane.org>
To: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

pre-requisite to shrink size of ieee80211_tx_info which in turn is
needed to shrink skb->cb to 40 bytes again.

Signed-off-by: Florian Westphal <fw-HFFVJYpyMKqzQB+pC5nmwQ@public.gmane.org>
---
 drivers/net/wireless/ath/ath9k/ath9k.h | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/wireless/ath/ath9k/ath9k.h b/drivers/net/wireless/ath/ath9k/ath9k.h
index 7e89236..a7a81b3 100644
--- a/drivers/net/wireless/ath/ath9k/ath9k.h
+++ b/drivers/net/wireless/ath/ath9k/ath9k.h
@@ -184,12 +184,12 @@ struct ath_frame_info {
 	struct ath_buf *bf;
 	u16 framelen;
 	s8 txq;
-	enum ath9k_key_type keytype;
 	u8 keyix;
 	u8 rtscts_rate;
 	u8 retries : 7;
 	u8 baw_tracked : 1;
 	u8 tx_power;
+	enum ath9k_key_type keytype:2;
 };
 
 struct ath_rxbuf {
-- 
2.0.5

--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
