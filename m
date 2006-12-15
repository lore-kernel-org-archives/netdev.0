From: Johannes Berg <johannes@sipsolutions.net>
Subject: [PATCH] d80211: add missing \n in skb queue warning
Date: Fri, 15 Dec 2006 15:56:15 +0100
Message-ID: <1166194575.3462.16.camel@johannes.berg>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	"John W. Linville" <linville@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from crystal.sipsolutions.net ([195.210.38.204]:55396 "EHLO
	sipsolutions.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752644AbWLOO4A (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 15 Dec 2006 09:56:00 -0500
To: Jiri Benc <jbenc@suse.cz>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This just adds a missing \n I noticed when I got the warning (see my
other mail)

Signed-off-by: Johannes Berg <johannes@sipsolutions.net>

--- wireless-dev.orig/net/d80211/ieee80211.c	2006-12-14 20:14:50.150611855 +0100
+++ wireless-dev/net/d80211/ieee80211.c	2006-12-14 20:14:55.118611855 +0100
@@ -4709,7 +4709,7 @@ void ieee80211_unregister_hw(struct ieee
 
 	if (skb_queue_len(&local->skb_queue)
 			|| skb_queue_len(&local->skb_queue_unreliable))
-		printk(KERN_WARNING "%s: skb_queue not empty",
+		printk(KERN_WARNING "%s: skb_queue not empty\n",
 		       local->mdev->name);
 	skb_queue_purge(&local->skb_queue);
 	skb_queue_purge(&local->skb_queue_unreliable);


