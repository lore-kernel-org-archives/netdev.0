From: Daniel Drake <dsd-aBrp7R+bbdUdnm+yROfE0A@public.gmane.org>
Subject: [PATCH RESEND] zd1211rw-mac80211: Use compare_ether_addr()
Date: Sun, 11 Mar 2007 19:18:57 +0000 (GMT)
Message-ID: <20070311191857.AA1157B409F@zog.reactivated.net>
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Cc: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Cc: kune-hUSrv6EASfkEnNRfnnE9gw@public.gmane.org
Cc: maxime-+3Uz/VIkGlWGglJvpFV4uA@public.gmane.org
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Suggested by Maxime Austruy, based on mac80211 changes from Stephen
Hemminger

Signed-off-by: Daniel Drake <dsd-aBrp7R+bbdUdnm+yROfE0A@public.gmane.org>
---
 drivers/net/wireless/mac80211/zd1211rw/zd_mac.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/wireless/mac80211/zd1211rw/zd_mac.c b/drivers/net/wireless/mac80211/zd1211rw/zd_mac.c
index 0d75ef2..94aa791 100644
--- a/drivers/net/wireless/mac80211/zd1211rw/zd_mac.c
+++ b/drivers/net/wireless/mac80211/zd1211rw/zd_mac.c
@@ -440,7 +440,7 @@ static int filter_ack(struct ieee80211_hw *dev, struct ieee80211_hdr *rx_hdr,
 
 	tx_hdr = (struct ieee80211_hdr *) skb->data;
 
-	if (!memcmp(tx_hdr->addr2, rx_hdr->addr1, ETH_ALEN))
+	if (!compare_ether_addr(tx_hdr->addr2, rx_hdr->addr1))
 		skb = __skb_dequeue(&mac->tx_queue);
 	else {
 		spin_unlock(&mac->tx_queue.lock);
-- 
1.5.0.3
