From: Francois Romieu <romieu@fr.zoreil.com>
Subject: [patch 3/7] 2.6.5-bk-netdev - r8169 queue
Date: Mon, 5 Apr 2004 23:58:02 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040405235802.C23436@electric-eye.fr.zoreil.com>
References: <20040405235545.A20805@electric-eye.fr.zoreil.com> <20040405235648.A23436@electric-eye.fr.zoreil.com> <20040405235726.B23436@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Jeff Garzik <jgarzik@pobox.com>
Content-Disposition: inline
In-Reply-To: <20040405235726.B23436@electric-eye.fr.zoreil.com>; from romieu@fr.zoreil.com on Mon, Apr 05, 2004 at 11:57:26PM +0200
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


Missing 'static' qualifier for functions.


 drivers/net/r8169.c |    9 +++------
 1 files changed, 3 insertions(+), 6 deletions(-)

diff -puN drivers/net/r8169.c~r8169-missing-static drivers/net/r8169.c
--- linux-2.6.5/drivers/net/r8169.c~r8169-missing-static	2004-04-05 23:05:53.000000000 +0200
+++ linux-2.6.5-fr/drivers/net/r8169.c	2004-04-05 23:05:53.000000000 +0200
@@ -346,8 +346,7 @@ static const unsigned int rtl8169_rx_con
 #define PHY_Cap_100_Half_Or_Less PHY_Cap_100_Half | PHY_Cap_10_Full_Or_Less
 #define PHY_Cap_100_Full_Or_Less PHY_Cap_100_Full | PHY_Cap_100_Half_Or_Less
 
-void
-mdio_write(void *ioaddr, int RegAddr, int value)
+static void mdio_write(void *ioaddr, int RegAddr, int value)
 {
 	int i;
 
@@ -364,8 +363,7 @@ mdio_write(void *ioaddr, int RegAddr, in
 	}
 }
 
-int
-mdio_read(void *ioaddr, int RegAddr)
+static int mdio_read(void *ioaddr, int RegAddr)
 {
 	int i, value = -1;
 
@@ -1642,8 +1640,7 @@ rtl8169_set_rx_mode(struct net_device *d
  *
  *  Get TX/RX statistics for rtl8169
  */
-struct net_device_stats *
-rtl8169_get_stats(struct net_device *dev)
+static struct net_device_stats *rtl8169_get_stats(struct net_device *dev)
 {
 	struct rtl8169_private *tp = dev->priv;
 	void *ioaddr = tp->mmio_addr;

_
