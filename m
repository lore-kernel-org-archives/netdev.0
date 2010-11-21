From: Joe Perches <joe-6d6DIl74uiNBDgjK7y7TUQ@public.gmane.org>
Subject: [PATCH 58/62] ray_cs: Use static const
Date: Sat, 20 Nov 2010 18:38:59 -0800
Message-ID: <e530e506090e3de049ea79098ccaa7665575db52.1290305776.git.joe@perches.com>
References: <cover.1290305773.git.joe@perches.com>
Cc: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: "John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <cover.1290305773.git.joe-6d6DIl74uiNBDgjK7y7TUQ@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Using static const generally increases object text and decreases data size.
It also generally decreases overall object size.

   text	   data	    bss	    dec	    hex	filename
  42607	   3581	   8536	  54724	   d5c4	drivers/net/wireless/ray_cs.o.new
  42603	   3585	   8536	  54724	   d5c4	drivers/net/wireless/ray_cs.o.old

Signed-off-by: Joe Perches <joe-6d6DIl74uiNBDgjK7y7TUQ@public.gmane.org>
---
 drivers/net/wireless/ray_cs.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/wireless/ray_cs.c b/drivers/net/wireless/ray_cs.c
index 97007d9..2b1cbba 100644
--- a/drivers/net/wireless/ray_cs.c
+++ b/drivers/net/wireless/ray_cs.c
@@ -2286,8 +2286,8 @@ static void untranslate(ray_dev_t *local, struct sk_buff *skb, int len)
 	struct ethhdr *peth;
 	UCHAR srcaddr[ADDRLEN];
 	UCHAR destaddr[ADDRLEN];
-	static UCHAR org_bridge[3] = { 0, 0, 0xf8 };
-	static UCHAR org_1042[3] = { 0, 0, 0 };
+	static const UCHAR org_bridge[3] = { 0, 0, 0xf8 };
+	static const UCHAR org_1042[3] = { 0, 0, 0 };
 
 	memcpy(destaddr, ieee80211_get_DA(pmac), ADDRLEN);
 	memcpy(srcaddr, ieee80211_get_SA(pmac), ADDRLEN);
-- 
1.7.3.2.245.g03276.dirty

--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
