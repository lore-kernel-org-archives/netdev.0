From: Jiri Olsa <olsajiri-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: [PATCH] net: Removing duplicit #includes
Date: Wed, 07 Nov 2007 10:09:18 +0100
Message-ID: <473180BE.9010400@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Removing duplicit #includes for net/
Signed-off-by: Jiri Olsa <olsajiri-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org> 
---
 net/core/dst.c                       |    1 -
 net/ieee80211/ieee80211_crypt_tkip.c |    1 -
 net/ieee80211/ieee80211_crypt_wep.c  |    1 -
 3 files changed, 0 insertions(+), 3 deletions(-)

diff --git a/net/core/dst.c b/net/core/dst.c
index 16958e6..03daead 100644
--- a/net/core/dst.c
+++ b/net/core/dst.c
@@ -18,7 +18,6 @@
 #include <linux/types.h>
 #include <net/net_namespace.h>
 
-#include <net/net_namespace.h>
 #include <net/dst.h>
 
 /*
diff --git a/net/ieee80211/ieee80211_crypt_tkip.c b/net/ieee80211/ieee80211_crypt_tkip.c
index 4cce353..58b2261 100644
--- a/net/ieee80211/ieee80211_crypt_tkip.c
+++ b/net/ieee80211/ieee80211_crypt_tkip.c
@@ -25,7 +25,6 @@
 #include <net/ieee80211.h>
 
 #include <linux/crypto.h>
-#include <linux/scatterlist.h>
 #include <linux/crc32.h>
 
 MODULE_AUTHOR("Jouni Malinen");
diff --git a/net/ieee80211/ieee80211_crypt_wep.c b/net/ieee80211/ieee80211_crypt_wep.c
index 866fc04..3fa30c4 100644
--- a/net/ieee80211/ieee80211_crypt_wep.c
+++ b/net/ieee80211/ieee80211_crypt_wep.c
@@ -22,7 +22,6 @@
 #include <net/ieee80211.h>
 
 #include <linux/crypto.h>
-#include <linux/scatterlist.h>
 #include <linux/crc32.h>
 
 MODULE_AUTHOR("Jouni Malinen");
