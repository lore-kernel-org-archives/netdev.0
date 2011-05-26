From: Jesper Juhl <jj@chaosbits.net>
Subject: [PATCH][Trivial] mac80211: Remove duplicate linux/slab.h include
 from net/mac80211/scan.c
Date: Thu, 26 May 2011 10:53:17 +0200 (CEST)
Message-ID: <alpine.LNX.2.00.1105261048570.17400@swampdragon.chaosbits.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Luciano Coelho <coelho@ti.com>,
	"John W. Linville" <linville@tuxdriver.com>,
	Johannes Berg <johannes@sipsolutions.net>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-wireless@vger.kernel.org, trivial@kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Commit 79f460ca49d8d5700756ab7071c951311c7f29cc add a duplicate 
linux/slab.h include to net/mac80211/scan.c - remove it.

Signed-off-by: Jesper Juhl <jj@chaosbits.net>
---
 scan.c |    1 -
 1 file changed, 1 deletion(-)

 patch against current Linus' tree

diff --git a/net/mac80211/scan.c b/net/mac80211/scan.c
index 27af672..58ffa7d 100644
--- a/net/mac80211/scan.c
+++ b/net/mac80211/scan.c
@@ -15,7 +15,6 @@
 #include <linux/if_arp.h>
 #include <linux/rtnetlink.h>
 #include <linux/pm_qos_params.h>
-#include <linux/slab.h>
 #include <net/sch_generic.h>
 #include <linux/slab.h>
 #include <net/mac80211.h>


-- 
Jesper Juhl <jj@chaosbits.net>       http://www.chaosbits.net/
Don't top-post http://www.catb.org/jargon/html/T/top-post.html
Plain text mails only, please.
