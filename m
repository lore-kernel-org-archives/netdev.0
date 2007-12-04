From: "John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
Subject: [PATCH] rt2x00: correct "skb_buff" typo
Date: Tue,  4 Dec 2007 17:24:35 -0500
Message-ID: <1196807075-28518-1-git-send-email-linville@tuxdriver.com>
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	"John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
To: jeff-o2qLIJkoznsdnm+yROfE0A@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Signed-off-by: John W. Linville <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
---
Jeff,

I found this one when pushing the latest round of wireless bits
into rawhide.  Wanna just go ahead and apply it to netdev-2.6#upstream?

John

 drivers/net/wireless/rt2x00/rt2x00lib.h |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/wireless/rt2x00/rt2x00lib.h b/drivers/net/wireless/rt2x00/rt2x00lib.h
index 0bf10ff..108488d 100644
--- a/drivers/net/wireless/rt2x00/rt2x00lib.h
+++ b/drivers/net/wireless/rt2x00/rt2x00lib.h
@@ -91,7 +91,7 @@ static inline void rt2x00debug_deregister(struct rt2x00_dev *rt2x00dev)
 }
 
 static inline void rt2x00debug_dump_frame(struct rt2x00_dev *rt2x00dev,
-					  struct skb_buff *skb)
+					  struct sk_buff *skb)
 {
 }
 #endif /* CONFIG_RT2X00_LIB_DEBUGFS */
-- 
1.5.3.3
