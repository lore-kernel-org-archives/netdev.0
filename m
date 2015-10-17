From: Paul McQuade <paulmcquad-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: [PATCH 1/3] net: wireless: rt2x00: Space issue
Date: Sat, 17 Oct 2015 22:06:43 +0100
Message-ID: <1445116005-28670-1-git-send-email-paulmcquad@gmail.com>
Cc: sgruszka-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, helmut.schaa-gM/Ye1E23mwN+BqQ9rBEUg@public.gmane.org,
	kvalo-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org, linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: paulmcquad-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Removed empty spaces before/after parenthesis

Signed-off-by: Paul McQuade <paulmcquad-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
---
 drivers/net/wireless/rt2x00/rt2x00.h | 24 ++++++++++++------------
 1 file changed, 12 insertions(+), 12 deletions(-)

diff --git a/drivers/net/wireless/rt2x00/rt2x00.h b/drivers/net/wireless/rt2x00/rt2x00.h
index 3282ddb..6f8310a 100644
--- a/drivers/net/wireless/rt2x00/rt2x00.h
+++ b/drivers/net/wireless/rt2x00/rt2x00.h
@@ -107,7 +107,7 @@
  * amount of bytes needed to move the data.
  */
 #define ALIGN_SIZE(__skb, __header) \
-	(  ((unsigned long)((__skb)->data + (__header))) & 3 )
+	(((unsigned long)((__skb)->data + (__header))) & 3)
 
 /*
  * Constants for extra TX headroom for alignment purposes.
@@ -128,14 +128,14 @@
 #define SLOT_TIME		20
 #define SHORT_SLOT_TIME		9
 #define SIFS			10
-#define PIFS			( SIFS + SLOT_TIME )
-#define SHORT_PIFS		( SIFS + SHORT_SLOT_TIME )
-#define DIFS			( PIFS + SLOT_TIME )
-#define SHORT_DIFS		( SHORT_PIFS + SHORT_SLOT_TIME )
-#define EIFS			( SIFS + DIFS + \
-				  GET_DURATION(IEEE80211_HEADER + ACK_SIZE, 10) )
-#define SHORT_EIFS		( SIFS + SHORT_DIFS + \
-				  GET_DURATION(IEEE80211_HEADER + ACK_SIZE, 10) )
+#define PIFS			(SIFS + SLOT_TIME)
+#define SHORT_PIFS		(SIFS + SHORT_SLOT_TIME)
+#define DIFS			(PIFS + SLOT_TIME)
+#define SHORT_DIFS		(SHORT_PIFS + SHORT_SLOT_TIME)
+#define EIFS			(SIFS + DIFS + \
+				  GET_DURATION(IEEE80211_HEADER + ACK_SIZE, 10))
+#define SHORT_EIFS		(SIFS + SHORT_DIFS + \
+				  GET_DURATION(IEEE80211_HEADER + ACK_SIZE, 10))
 
 enum rt2x00_chip_intf {
 	RT2X00_CHIP_INTF_PCI,

-- 
2.6.1

--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
