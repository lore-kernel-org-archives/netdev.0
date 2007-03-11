From: Daniel Drake <dsd-aBrp7R+bbdUdnm+yROfE0A@public.gmane.org>
Subject: [PATCH] zd1211rw-mac80211: sparse-annotate radiotap header
Date: Sun, 11 Mar 2007 17:54:06 +0000 (GMT)
Message-ID: <20070311175406.823497B409F@zog.reactivated.net>
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Cc: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Cc: kune-hUSrv6EASfkEnNRfnnE9gw@public.gmane.org
Cc: proski-mXXj517/zsQ@public.gmane.org
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Pavel Roskin <proski-mXXj517/zsQ@public.gmane.org>

All fields in radiotap header must be little endian.  The driver does it
correctly, but the structure definition must be annotated.

Signed-off-by: Pavel Roskin <proski-mXXj517/zsQ@public.gmane.org>
Signed-off-by: Ulrich Kunitz <kune-hUSrv6EASfkEnNRfnnE9gw@public.gmane.org>
Signed-off-by: Daniel Drake <dsd-aBrp7R+bbdUdnm+yROfE0A@public.gmane.org>
---
 drivers/net/wireless/mac80211/zd1211rw/zd_mac.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/wireless/mac80211/zd1211rw/zd_mac.c b/drivers/net/wireless/mac80211/zd1211rw/zd_mac.c
index b69688c..0d75ef2 100644
--- a/drivers/net/wireless/zd1211rw/drivers/net/wireless/mac80211/zd1211rw/zd_mac.c
+++ b/drivers/net/wireless/zd1211rw/drivers/net/wireless/mac80211/zd1211rw/zd_mac.c
@@ -359,8 +359,8 @@ struct zd_rt_hdr {
 	struct ieee80211_radiotap_header rt_hdr;
 	u8  rt_flags;
 	u8  rt_rate;
-	u16 rt_channel;
-	u16 rt_chbitmask;
+	__le16 rt_channel;
+	__le16 rt_chbitmask;
 } __attribute__((packed));
 
 static void fill_rt_header(void *buffer, struct zd_mac *mac,
-- 
1.5.0.3
