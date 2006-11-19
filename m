From: Johannes Berg <johannes@sipsolutions.net>
Subject: [PATCH 9/13] d80211: remove useless driver name field
Date: Sun, 19 Nov 2006 20:30:16 +0100
Message-ID: <1163964616.15473.57.camel@johannes.berg>
References: <1163802439.3392.47.camel@johannes.berg>
	 <1163963898.15473.36.camel@johannes.berg>
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
Received: from crystal.sipsolutions.net ([195.210.38.204]:14006 "EHLO
	sipsolutions.net") by vger.kernel.org with ESMTP id S933065AbWKSTce
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 19 Nov 2006 14:32:34 -0500
To: netdev@vger.kernel.org
In-Reply-To: <1163963898.15473.36.camel@johannes.berg>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

struct ieee80211_ops has a driver name field that's never used.
Remove it.

Signed-off-by: Johannes Berg <johannes@sipsolutions.net>

--- wireless-dev.orig/include/net/d80211.h	2006-11-19 20:14:00.039275208 +0100
+++ wireless-dev/include/net/d80211.h	2006-11-19 20:14:00.639275208 +0100
@@ -531,9 +531,6 @@ struct ieee80211_hw {
  * about supported hardware features and to pass function pointers to callback
  * functions. */
 struct ieee80211_ops {
-	/* Driver name */
-	char *name;
-
 	/* Handler that 802.11 module calls for each transmitted frame.
 	 * skb contains the buffer starting from the IEEE 802.11 header.
 	 * The low-level driver should send the frame out based on


