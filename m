From: Alexander Aring <alex.aring-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: [PATCH bluetooth-next 01/10] 6lowpan: clarify Kconfig entries for upcoming GHC support
Date: Wed,  9 Dec 2015 22:46:22 +0100
Message-ID: <1449697591-15991-2-git-send-email-alex.aring@gmail.com>
References: <1449697591-15991-1-git-send-email-alex.aring@gmail.com>
Cc: linux-bluetooth-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	kernel-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org, Stefan Schmidt <stefan-JPH+aEBZ4P+UEJcrhfAQsw@public.gmane.org>,
	Alexander Aring <alex.aring-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
To: linux-wpan-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-bluetooth-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1449697591-15991-1-git-send-email-alex.aring-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Sender: linux-bluetooth-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Stefan Schmidt <stefan-JPH+aEBZ4P+UEJcrhfAQsw@public.gmane.org>

Acked-by: Jukka Rissanen <jukka.rissanen-VuQAYsv1563Yd54FQh9/CA@public.gmane.org>
Signed-off-by: Stefan Schmidt <stefan-JPH+aEBZ4P+UEJcrhfAQsw@public.gmane.org>
Signed-off-by: Alexander Aring <alex.aring-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
---
 net/6lowpan/Kconfig | 5 +++--
 1 file changed, 3 insertions(+), 2 deletions(-)

diff --git a/net/6lowpan/Kconfig b/net/6lowpan/Kconfig
index 7fa0f38..6af7a46 100644
--- a/net/6lowpan/Kconfig
+++ b/net/6lowpan/Kconfig
@@ -6,11 +6,12 @@ menuconfig 6LOWPAN
 	  "6LoWPAN" which is supported by IEEE 802.15.4 or Bluetooth stacks.
 
 menuconfig 6LOWPAN_NHC
-	tristate "Next Header Compression Support"
+	tristate "Next Header and Generic Header Compression Support"
 	depends on 6LOWPAN
 	default y
 	---help---
-	  Support for next header compression.
+	  Support for next header and generic header compression defined in
+	  RFC6282 and RFC7400.
 
 if 6LOWPAN_NHC
 
-- 
2.6.1
