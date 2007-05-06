From: Geert Uytterhoeven <geert@linux-m68k.org>
Subject: [PATCH] mac80211: include <linux/delay.h> instead of <asm/delay.h>
Date: Sun, 6 May 2007 22:37:17 +0200 (CEST)
Message-ID: <Pine.LNX.4.64.0705062236030.4741@anakin>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@vger.kernel.org,
	Linux Kernel Development <linux-kernel@vger.kernel.org>
To: Linus Torvalds <torvalds@osdl.org>, Andrew Morton <akpm@osdl.org>,
	Jiri Benc <jbenc@suse.cz>,
	"John W. Linville" <linville@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from adicia.telenet-ops.be ([195.130.132.56]:42629 "EHLO
	adicia.telenet-ops.be" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753144AbXEFUhY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 6 May 2007 16:37:24 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

|   CC      net/mac80211/ieee80211_sta.o
| In file included from linux/net/mac80211/ieee80211_sta.c:31:
| include2/asm/delay.h: In function '__const_udelay':
| include2/asm/delay.h:33: error: 'loops_per_jiffy' undeclared (first use in this function)
| include2/asm/delay.h:33: error: (Each undeclared identifier is reported only once
| include2/asm/delay.h:33: error: for each function it appears in.)

mac80211: include <linux/delay.h> instead of <asm/delay.h>

Signed-off-by: Geert Uytterhoeven <geert@linux-m68k.org>
---
 net/mac80211/ieee80211_sta.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

--- linux-m68k-2.6.21.orig/net/mac80211/ieee80211_sta.c
+++ linux-m68k-2.6.21/net/mac80211/ieee80211_sta.c
@@ -17,6 +17,7 @@
  * scan result table filtering (by capability (privacy, IBSS/BSS, WPA/RSN IE,
  *    SSID)
  */
+#include <linux/delay.h>
 #include <linux/if_ether.h>
 #include <linux/skbuff.h>
 #include <linux/netdevice.h>
@@ -27,7 +28,6 @@
 #include <linux/rtnetlink.h>
 #include <net/iw_handler.h>
 #include <asm/types.h>
-#include <asm/delay.h>
 
 #include <net/mac80211.h>
 #include "ieee80211_i.h"

Gr{oetje,eeting}s,

						Geert

--
Geert Uytterhoeven -- There's lots of Linux beyond ia32 -- geert@linux-m68k.org

In personal conversations with technical people, I call myself a hacker. But
when I'm talking to journalists I just say "programmer" or something like that.
							    -- Linus Torvalds
