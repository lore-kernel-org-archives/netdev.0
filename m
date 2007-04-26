From: akpm@linux-foundation.org
Subject: [patch 01/11] git-netdev-all: export ieee80211_debug_level
Date: Thu, 26 Apr 2007 00:23:14 -0700
Message-ID: <200704260723.l3Q7NE1I023820@shell0.pdx.osdl.net>
Cc: netdev@vger.kernel.org, akpm@linux-foundation.org, dsd@gentoo.org,
	johannes@sipsolutions.net, josejx@gentoo.org
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([65.172.181.25]:46571 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S933159AbXDZHYc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Apr 2007 03:24:32 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Andrew Morton <akpm@linux-foundation.org>

Someone has been forgetting their SubmitChecklist medicine.

ERROR: "ieee80211_debug_level" [net/ieee80211/ieee80211_crypt_ccmp.ko] undefined!

Fix some unneeded space-wasting initialisations, too.  How often must this be
said?

Cc: Johannes Berg <johannes@sipsolutions.net>
Cc: Joe Jezak <josejx@gentoo.org>
Cc: Daniel Drake <dsd@gentoo.org>
Cc: Jeff Garzik <jeff@garzik.org>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
---

 net/ieee80211/ieee80211_module.c |    8 +++++---
 1 file changed, 5 insertions(+), 3 deletions(-)

diff -puN net/ieee80211/ieee80211_module.c~git-netdev-all-export-ieee80211_debug_level net/ieee80211/ieee80211_module.c
--- a/net/ieee80211/ieee80211_module.c~git-netdev-all-export-ieee80211_debug_level
+++ a/net/ieee80211/ieee80211_module.c
@@ -227,9 +227,11 @@ void free_ieee80211(struct net_device *d
 
 #ifdef CONFIG_IEEE80211_DEBUG
 
-static int debug = 0;
-u32 ieee80211_debug_level = 0;
-static struct proc_dir_entry *ieee80211_proc = NULL;
+static int debug;
+u32 ieee80211_debug_level;
+static struct proc_dir_entry *ieee80211_proc;
+
+EXPORT_SYMBOL(ieee80211_debug_level);
 
 static int show_debug_level(char *page, char **start, off_t offset,
 			    int count, int *eof, void *data)
_
