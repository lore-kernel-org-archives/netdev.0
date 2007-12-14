From: David Woodhouse <dwmw2-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org>
Subject: Re: [PATCH] PS3: gelic: Add wireless support for PS3
Date: Fri, 14 Dec 2007 01:48:52 -0500
Message-ID: <1197614933.3798.36.camel@shinybook.infradead.org>
References: <20071213211626.BF8E.MOKUNO@sm.sony.co.jp>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	geoffrey.levand-mEdOJwZ7QcZBDgjK7y7TUQ@public.gmane.org,
	Geert Uytterhoeven <Geert.Uytterhoeven-osDt5Q4Chk1BDgjK7y7TUQ@public.gmane.org>
To: Masakazu Mokuno <mokuno-DfbDroY8Xu1L9jVzuh4AOg@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20071213211626.BF8E.MOKUNO-DfbDroY8Xu1L9jVzuh4AOg@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

--- linux-2.6.23.ppc64/drivers/net/ps3_gelic_net.c~	2007-12-14 01:31:50.000000000 -0500
+++ linux-2.6.23.ppc64/drivers/net/ps3_gelic_net.c	2007-12-14 01:39:25.000000000 -0500
@@ -1139,7 +1139,7 @@ static irqreturn_t gelic_card_interrupt(
  *
  * see Documentation/networking/netconsole.txt
  */
-static void gelic_net_poll_controller(struct net_device *netdev)
+void gelic_net_poll_controller(struct net_device *netdev)
 {
 	struct gelic_card *card = netdev_card(netdev);
 
--- linux-2.6.23.ppc64/drivers/net/ps3_gelic_net.h~	2007-12-14 01:31:50.000000000 -0500
+++ linux-2.6.23.ppc64/drivers/net/ps3_gelic_net.h	2007-12-14 01:39:47.000000000 -0500
@@ -346,6 +346,7 @@ extern void gelic_net_tx_timeout(struct 
 extern int gelic_net_change_mtu(struct net_device *netdev, int new_mtu);
 extern int gelic_net_setup_netdev(struct net_device *netdev,
 				  struct gelic_card *card);
+extern void gelic_net_poll_controller(struct net_device *netdev);
 
 /* shared ethtool ops */
 extern void gelic_net_get_drvinfo(struct net_device *netdev,

-- 
dwmw2
