From: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
Subject: [PATCH 6/9] wext: move EXPORT_SYMBOL statements where they belong
Date: Tue, 24 Apr 2007 20:07:38 +0200
Message-ID: <20070424180849.235352000@sipsolutions.net>
References: <20070424180732.371620000@sipsolutions.net>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	jt-sDzT885Ts8HQT0dZR+AlfA@public.gmane.org
To: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline; filename=move-wext-exports.patch
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

EXPORT_SYMBOL statements are supposed to go together with the symbol
they're exporting. This patch moves them accordingly.

Signed-off-by: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>

---
 net/wireless/wext.c |   11 +++++------
 1 file changed, 5 insertions(+), 6 deletions(-)

--- net-2.6.22.orig/net/wireless/wext.c	2007-04-24 19:11:11.888804911 +0200
+++ net-2.6.22/net/wireless/wext.c	2007-04-24 19:12:44.288804911 +0200
@@ -1279,6 +1279,7 @@ void wireless_send_event(struct net_devi
 
 	return;		/* Always success, I guess ;-) */
 }
+EXPORT_SYMBOL(wireless_send_event);
 
 /********************** ENHANCED IWSPY SUPPORT **********************/
 /*
@@ -1356,6 +1357,7 @@ int iw_handler_set_spy(struct net_device
 
 	return 0;
 }
+EXPORT_SYMBOL(iw_handler_set_spy);
 
 /*------------------------------------------------------------------*/
 /*
@@ -1391,6 +1393,7 @@ int iw_handler_get_spy(struct net_device
 		spydata->spy_stat[i].updated &= ~IW_QUAL_ALL_UPDATED;
 	return 0;
 }
+EXPORT_SYMBOL(iw_handler_get_spy);
 
 /*------------------------------------------------------------------*/
 /*
@@ -1417,6 +1420,7 @@ int iw_handler_set_thrspy(struct net_dev
 
 	return 0;
 }
+EXPORT_SYMBOL(iw_handler_set_thrspy);
 
 /*------------------------------------------------------------------*/
 /*
@@ -1440,6 +1444,7 @@ int iw_handler_get_thrspy(struct net_dev
 
 	return 0;
 }
+EXPORT_SYMBOL(iw_handler_get_thrspy);
 
 /*------------------------------------------------------------------*/
 /*
@@ -1516,10 +1521,4 @@ void wireless_spy_update(struct net_devi
 		}
 	}
 }
-
-EXPORT_SYMBOL(iw_handler_get_spy);
-EXPORT_SYMBOL(iw_handler_get_thrspy);
-EXPORT_SYMBOL(iw_handler_set_spy);
-EXPORT_SYMBOL(iw_handler_set_thrspy);
-EXPORT_SYMBOL(wireless_send_event);
 EXPORT_SYMBOL(wireless_spy_update);

--
