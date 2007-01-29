From: Jiri Benc <jbenc@suse.cz>
Subject: d80211: a patch for standalone d80211 tarball
Date: Mon, 29 Jan 2007 18:48:12 +0100 (CET)
Message-ID: <20070129174812.7D1E94849E@silver.suse.cz>
References: <20070129184707.885764375.midnight@suse.cz>
Cc: "John W. Linville" <linville@tuxdriver.com>,
	James Ketrenos <jketreno@linux.intel.com>,
	Ivo van Doorn <ivdoorn@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from styx.suse.cz ([82.119.242.94]:41734 "EHLO silver.suse.cz"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752535AbXA2RsA (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 29 Jan 2007 12:48:00 -0500
In-Reply-To: <20070129184707.885764375.midnight@suse.cz>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch should be enough to allow creation of standalone d80211 tarball
(i.e. version of d80211 that could be compiled without patching the vanilla
kernel) after "invisible master interface" patches.

It is completely untested.

Signed-off-by: Jiri Benc <jbenc@suse.cz>

---
 net/d80211/ieee80211_i.h |    4 ++++
 1 files changed, 4 insertions(+)

--- dscape.orig/net/d80211/ieee80211_i.h
+++ dscape/net/d80211/ieee80211_i.h
@@ -26,6 +26,10 @@
 /* ieee80211.o internal definitions, etc. These are not included into
  * low-level drivers. */
 
+#define ieee80211_ptr	ax25_ptr
+#define register_invisible_netdevice	register_netdevice
+#define unregister_invisible_netdevice	unregister_netdevice
+
 #ifndef ETH_P_PAE
 #define ETH_P_PAE 0x888E /* Port Access Entity (IEEE 802.1X) */
 #endif /* ETH_P_PAE */
