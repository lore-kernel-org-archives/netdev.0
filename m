From: Jay Vosburgh <fubar@us.ibm.com>
Subject: [PATCH 2.6.11-rc3 3/5] bonding: change misleading warning
Date: Fri, 11 Feb 2005 01:17:22 -0800
Message-ID: <200502110917.j1B9HMtN003672@death.nxdomain.ibm.com>
Cc: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-bounce@oss.sgi.com>
To: bonding-devel@lists.sourceforge.net, netdev@oss.sgi.com
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


	This updates a warning message that the bonding driver issues
when some modes are unable to determine the link speed of a slave
device.  The old message led users to believe that bonding was slowing
their gigabit devices to 100 Mb/sec.

Signed-off-by: Jay Vosburgh <fubar@us.ibm.com>

Index: linux-2611-rc3/drivers/net/bonding/bond_main.c
===================================================================
RCS file: /sda7/CVS/linux-2611-rc3/linux-2611-rc3/drivers/net/bonding/bond_main.c,v
retrieving revision 1.2
diff -u -u -r1.2 bond_main.c
--- linux-2611-rc3/drivers/net/bonding/bond_main.c	11 Feb 2005 06:57:08 -0000	1.2
+++ linux-2611-rc3/drivers/net/bonding/bond_main.c	11 Feb 2005 07:00:02 -0000
@@ -1849,8 +1849,8 @@
 	if (bond_update_speed_duplex(new_slave) &&
 	    (new_slave->link != BOND_LINK_DOWN)) {
 		printk(KERN_WARNING DRV_NAME
-		       ": Warning: failed to get speed/duplex from %s, speed "
-		       "forced to 100Mbps, duplex forced to Full.\n",
+		       ": Warning: failed to get speed and duplex from %s, "
+		       "assumed to be 100Mb/sec and Full.\n",
 		       new_slave->dev->name);
 
 		if (bond->params.mode == BOND_MODE_8023AD) {
