From: Adrian Bunk <bunk@stusta.de>
Subject: [-mm patch] include/net/ieee80211.h must #include <linux/wireless.h>
Date: Fri, 22 Jul 2005 23:39:12 +0200
Message-ID: <20050722213912.GU3160@stusta.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel=40m.gmane.org-S262185AbVGVVjU@vger.kernel.org>
To: jgarzik@pobox.com, jkmaline@cc.hut.fi, hostap@shmoo.com
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

-Wundef found an (although perhaps harmless) bug:

<--  snip  -->

...
  CC      net/ieee80211/ieee80211_crypt.o
In file included from net/ieee80211/ieee80211_crypt.c:21:
include/net/ieee80211.h:26:5: warning: "WIRELESS_EXT" is not defined
  CC      net/ieee80211/ieee80211_crypt_wep.o
In file included from net/ieee80211/ieee80211_crypt_wep.c:20:
include/net/ieee80211.h:26:5: warning: "WIRELESS_EXT" is not defined
  CC      net/ieee80211/ieee80211_crypt_ccmp.o
  CC      net/ieee80211/ieee80211_crypt_tkip.o
In file included from net/ieee80211/ieee80211_crypt_tkip.c:23:
include/net/ieee80211.h:26:5: warning: "WIRELESS_EXT" is not defined
...

<--  snip  -->


Signed-off-by: Adrian Bunk <bunk@stusta.de>

--- linux-2.6.13-rc3-mm1-full/include/net/ieee80211.h.old	2005-07-22 18:37:57.000000000 +0200
+++ linux-2.6.13-rc3-mm1-full/include/net/ieee80211.h	2005-07-22 18:38:10.000000000 +0200
@@ -22,6 +22,7 @@
 #define IEEE80211_H
 #include <linux/if_ether.h> /* ETH_ALEN */
 #include <linux/kernel.h>   /* ARRAY_SIZE */
+#include <linux/wireless.h>
 
 #if WIRELESS_EXT < 17
 #define IW_QUAL_QUAL_INVALID   0x10
