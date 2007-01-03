From: Jiri Benc <jbenc@suse.cz>
Subject: [PATCH 6/12] d80211: add missing \n in skb queue warning
Date: Wed,  3 Jan 2007 19:05:14 +0100 (CET)
Message-ID: <20070103180514.517F73AA7EF@silver.suse.cz>
References: <20070103190418.710197000.midnight@suse.cz>
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from styx.suse.cz ([82.119.242.94]:42227 "EHLO silver.suse.cz"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751024AbXACSFP (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 3 Jan 2007 13:05:15 -0500
To: "John W. Linville" <linville@tuxdriver.com>
In-Reply-To: <20070103190418.710197000.midnight@suse.cz>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Johannes Berg <johannes@sipsolutions.net>

This just adds a missing \n I noticed when I got the warning (see my
other mail)

Signed-off-by: Johannes Berg <johannes@sipsolutions.net>
Signed-off-by: Jiri Benc <jbenc@suse.cz>

---

 net/d80211/ieee80211.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

f069487d2f2a306471ed1d5fca0ed5a00730ddef
diff --git a/net/d80211/ieee80211.c b/net/d80211/ieee80211.c
index c528be1..c833642 100644
--- a/net/d80211/ieee80211.c
+++ b/net/d80211/ieee80211.c
@@ -4683,7 +4683,7 @@ void ieee80211_unregister_hw(struct ieee
 
 	if (skb_queue_len(&local->skb_queue)
 			|| skb_queue_len(&local->skb_queue_unreliable))
-		printk(KERN_WARNING "%s: skb_queue not empty",
+		printk(KERN_WARNING "%s: skb_queue not empty\n",
 		       local->mdev->name);
 	skb_queue_purge(&local->skb_queue);
 	skb_queue_purge(&local->skb_queue_unreliable);
-- 
1.3.0

