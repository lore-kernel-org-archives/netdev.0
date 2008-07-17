From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: [PATCH 5/31]: mac80211: Temporarily mark QoS support BROKEN.
Date: Thu, 17 Jul 2008 05:16:04 -0700 (PDT)
Message-ID: <20080717.051604.22239818.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kaber-dcUjhNyLwpNeoWH0uzbU5w@public.gmane.org, johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org


We will undo this after a few changsets.

Signed-off-by: David S. Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
---
 net/mac80211/Kconfig |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/net/mac80211/Kconfig b/net/mac80211/Kconfig
index d203841..10579de 100644
--- a/net/mac80211/Kconfig
+++ b/net/mac80211/Kconfig
@@ -15,6 +15,7 @@ config MAC80211_QOS
 	def_bool y
 	depends on MAC80211
 	depends on NET_SCHED
+	depends on BROKEN
 
 comment "QoS/HT support disabled"
 	depends on MAC80211 && !MAC80211_QOS
-- 
1.5.6.2.255.gbed62

--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
