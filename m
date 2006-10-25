From: David Kimdon <david.kimdon@devicescape.com>
Subject: d80211: remove unused variable in ieee80211_rx_irqsafe
Date: Wed, 25 Oct 2006 11:16:21 -0700
Message-ID: <20061025181621.GA26738@devicescape.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "John W. Linville" <linville@tuxdriver.com>,
	Jiri Benc <jbenc@suse.cz>,
	David Kimdon <david.kimdon@devicescape.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.devicescape.com ([207.138.119.2]:6040 "EHLO
	mail.devicescape.com") by vger.kernel.org with ESMTP
	id S1030400AbWJYSQ2 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 25 Oct 2006 14:16:28 -0400
To: netdev@vger.kernel.org
Content-Disposition: inline; filename="ieee80211_rx_irqsafe-unused.patch"
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

tmp is unused.

Signed-off-by: David Kimdon <david.kimdon@devicescape.com>

Index: wireless-dev/net/d80211/ieee80211.c
===================================================================
--- wireless-dev.orig/net/d80211/ieee80211.c
+++ wireless-dev/net/d80211/ieee80211.c
@@ -3843,7 +3843,7 @@ void ieee80211_rx_irqsafe(struct net_dev
 			  struct ieee80211_rx_status *status)
 {
 	struct ieee80211_local *local = dev->ieee80211_ptr;
-	struct ieee80211_rx_status *saved, *tmp;
+	struct ieee80211_rx_status *saved;
 
 	skb->dev = dev;
 	saved = kmalloc(sizeof(struct ieee80211_rx_status), GFP_ATOMIC);

--
