From: Francois Romieu <romieu@fr.zoreil.com>
Subject: [patch 2.6.11-rc4-netdev1 4/4] ieee80211: offset_in_page() removal
Date: Mon, 14 Feb 2005 00:28:37 +0100
Message-ID: <20050213232837.GC2898@electric-eye.fr.zoreil.com>
References: <420FBAD3.3020909@pobox.com> <20050213232421.GB2060@electric-eye.fr.zoreil.com> <20050213232559.GA2898@electric-eye.fr.zoreil.com> <20050213232729.GB2898@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Stephen Hemminger <shemminger@osdl.org>, Randy Dunlap <rddunlap@osdl.org>,
        James Ketrenos <jketreno@linux.intel.com>
To: Jeff Garzik <jgarzik@pobox.com>, netdev@oss.sgi.com
Content-Disposition: inline
In-Reply-To: <20050213232729.GB2898@electric-eye.fr.zoreil.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

offset_in_page() removal.

Signed-off-by: Francois Romieu <romieu@fr.zoreil.com>

diff -puN include/net/ieee80211.h~80211-030 include/net/ieee80211.h
--- a/include/net/ieee80211.h~80211-030	2005-02-14 00:10:56.416908756 +0100
+++ b/include/net/ieee80211.h	2005-02-14 00:10:56.419908268 +0100
@@ -884,9 +884,4 @@ static inline const char *escape_essid(c
 	*d = '\0';
 	return escaped;
 }
-
-#ifndef offset_in_page
-#define offset_in_page(p) ((unsigned long)(p) & ~PAGE_MASK)
-#endif
-
 #endif /* IEEE80211_H */

_
