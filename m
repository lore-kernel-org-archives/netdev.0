From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: [PATCH] wireless: Make COMPAT_NETLINK_MESSAGES depend upon
 WEXT_CORE
Date: Mon, 26 Jul 2010 13:15:06 -0700 (PDT)
Message-ID: <20100726.131506.245381776.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org


WIRELESS_EXT is not the correct dependency.

Signed-off-by: David S. Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
---

Wireless folks, just FYI, I will commit this to net-next-2.6

 net/Kconfig |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/net/Kconfig b/net/Kconfig
index b325094..e24fa08 100644
--- a/net/Kconfig
+++ b/net/Kconfig
@@ -32,7 +32,7 @@ config WANT_COMPAT_NETLINK_MESSAGES
 config COMPAT_NETLINK_MESSAGES
 	def_bool y
 	depends on COMPAT
-	depends on WIRELESS_EXT || WANT_COMPAT_NETLINK_MESSAGES
+	depends on WEXT_CORE || WANT_COMPAT_NETLINK_MESSAGES
 	help
 	  This option makes it possible to send different netlink messages
 	  to tasks depending on whether the task is a compat task or not. To
-- 
1.7.1.1

--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
