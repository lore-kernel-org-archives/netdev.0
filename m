From: Joe Perches <joe@perches.com>
Subject: [PATCH] include/net/ieee80211.h - remove duplicate include
Date: Sun, 09 Mar 2008 16:55:10 -0700
Message-ID: <1205106910.656.99.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	LKML <linux-kernel@vger.kernel.org>
To: "John W. Linville" <linville@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 136-022.dsl.labridge.com ([206.117.136.22]:4376 "EHLO
	mail.perches.com" rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org
	with ESMTP id S1754028AbYCIX55 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 9 Mar 2008 19:57:57 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Joe Perches <joe@perches.com>

 include/net/ieee80211.h |    1 -
 1 files changed, 0 insertions(+), 1 deletions(-)

diff --git a/include/net/ieee80211.h b/include/net/ieee80211.h
index 285b2ad..529816b 100644
--- a/include/net/ieee80211.h
+++ b/include/net/ieee80211.h
@@ -183,7 +183,6 @@ const char *escape_essid(const char *essid, u8 essid_len);
 #define IEEE80211_DEBUG_RX(f, a...)  IEEE80211_DEBUG(IEEE80211_DL_RX, f, ## a)
 #define IEEE80211_DEBUG_QOS(f, a...)  IEEE80211_DEBUG(IEEE80211_DL_QOS, f, ## a)
 #include <linux/netdevice.h>
-#include <linux/wireless.h>
 #include <linux/if_arp.h>	/* ARPHRD_ETHER */
 
 #ifndef WIRELESS_SPY


