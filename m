From: David Kimdon <david.kimdon@devicescape.com>
Subject: [patch] d80211: fix kernel doc for ieee80211_get_buffered_bc
Date: Wed, 18 Oct 2006 15:44:05 -0700
Message-ID: <20061018224405.GA18644@devicescape.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "John W. Linville" <linville@tuxdriver.com>,
	Jiri Benc <jbenc@suse.cz>,
	David Kimdon <david.kimdon@devicescape.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.devicescape.com ([207.138.119.2]:12513 "EHLO
	mail.devicescape.com") by vger.kernel.org with ESMTP
	id S1423099AbWJRWoG (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 18 Oct 2006 18:44:06 -0400
To: netdev@vger.kernel.org
Content-Disposition: inline; filename="d80211-docs.patch"
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

ieee80211_beacon_get() was already described. The doc entry in
question describes ieee80211_get_buffered_bc().

Signed-off-by: David Kimdon <david.kimdon@devicescape.com>

Index: wireless-dev/include/net/d80211.h
===================================================================
--- wireless-dev.orig/include/net/d80211.h
+++ wireless-dev/include/net/d80211.h
@@ -782,7 +782,7 @@ struct sk_buff * ieee80211_beacon_get(st
 				      struct ieee80211_tx_control *control);
 
 /**
- * ieee80211_beacon_get - accessing buffered broadcast and multicast frames
+ * ieee80211_get_buffered_bc - accessing buffered broadcast and multicast frames
  * @dev: pointer to &struct net_device as obtained from
  *	ieee80211_alloc_hw().
  * @if_id: interface ID from &struct ieee80211_if_init_conf.

--
