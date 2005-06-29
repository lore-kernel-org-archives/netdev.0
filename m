From: Jeff Garzik <jgarzik@pobox.com>
Subject: [PATCH] ieee80211.h build fix
Date: Wed, 29 Jun 2005 01:17:55 -0400
Message-ID: <20050629051755.GA1061@havoc.gtf.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel=40m.gmane.org-S262412AbVF2FSC@vger.kernel.org>
To: Andrew Morton <akpm@osdl.org>, Linus Torvalds <torvalds@osdl.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


This crept in with the resync-to-mainline.  Nothing uses 802.11-crypt in
mainline, so we can safely comment it out for now.

Signed-off-by: Jeff Garzik <jgarzik@pobox.com>


diff --git a/include/net/ieee80211.h b/include/net/ieee80211.h
--- a/include/net/ieee80211.h
+++ b/include/net/ieee80211.h
@@ -426,7 +426,9 @@ struct ieee80211_stats {
 
 struct ieee80211_device;
 
+#if 0 /* for later */
 #include "ieee80211_crypt.h"
+#endif
 
 #define SEC_KEY_1         (1<<0)
 #define SEC_KEY_2         (1<<1)
