From: Johannes Berg <johannes@sipsolutions.net>
Subject: [PATCH] d80211: remove useless driver name field
Date: Fri, 17 Nov 2006 23:50:35 +0100
Message-ID: <1163803835.3392.52.camel@johannes.berg>
References: <1163802439.3392.47.camel@johannes.berg>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Jiri Benc <jbenc@suse.cz>,
	"John W. Linville" <linville@tuxdriver.com>,
	Simon Barber <simon@devicescape.com>,
	Jouni Malinen <jkm@devicescape.com>,
	Hong Liu <hong.liu@intel.com>,
	David Kimdon <david.kimdon@devicescape.com>,
	Michael Wu <flamingice@sourmilk.net>,
	Michael Buesch <mbuesch@freenet.de>,
	Ivo van Doorn <ivdoorn@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from crystal.sipsolutions.net ([195.210.38.204]:28622 "EHLO
	sipsolutions.net") by vger.kernel.org with ESMTP id S1756011AbWKQWwQ
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 17 Nov 2006 17:52:16 -0500
To: netdev@vger.kernel.org
In-Reply-To: <1163802439.3392.47.camel@johannes.berg>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

struct ieee80211_ops has a driver name field that's never used.
Remove it.

Signed-off-by: Johannes Berg <johannes@sipsolutions.net>

---
applies after the 10 patches

--- wireless-dev.orig/include/net/d80211.h	2006-11-17 23:37:10.249703408 +0100
+++ wireless-dev/include/net/d80211.h	2006-11-17 23:37:21.709703408 +0100
@@ -531,9 +531,6 @@ struct ieee80211_wiphy {
  * about supported hardware features and to pass function pointers to callback
  * functions. */
 struct ieee80211_ops {
-	/* Driver name */
-	char *name;
-
 	/* Handler that 802.11 module calls for each transmitted frame.
 	 * skb contains the buffer starting from the IEEE 802.11 header.
 	 * The low-level driver should send the frame out based on


