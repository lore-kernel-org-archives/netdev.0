From: Jay Vosburgh <fubar@us.ibm.com>
Subject: [PATCH 2.6.11-rc3 4/5] bonding: Update kconfig description
Date: Fri, 11 Feb 2005 01:17:42 -0800
Message-ID: <200502110917.j1B9HgGi003684@death.nxdomain.ibm.com>
Cc: "David S. Miller" <davem@davemloft.net>,
        Mitch Williams <mitch.a.williams@intel.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: bonding-devel@lists.sourceforge.net, netdev@oss.sgi.com
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


This patch updates the very-outdated Kconfig description for bonding.
Users reading the help text in menuconfig or xconfig would see text that
implied that bonding only supports static link aggregation, and required a
specific switch to make it work.  The new description mentions multiple
bonding modes and points the user to the bonding.txt documentation.

Signed-off-by:  Mitch Williams <mitch.a.williams@intel.com>
Signed-off-by: Jay Vosburgh <fubar@us.ibm.com>

diff -urpN -X dontdiff linux-2.6.10-clean/drivers/net/Kconfig linux-2.6.10/drivers/net/Kconfig
--- linux-2.6.10-clean/drivers/net/Kconfig	2004-12-24 13:35:25.000000000 -0800
+++ linux-2.6.10/drivers/net/Kconfig	2005-02-08 14:05:06.000000000 -0800
@@ -47,16 +47,13 @@ config BONDING
 	---help---
 	  Say 'Y' or 'M' if you wish to be able to 'bond' multiple Ethernet
 	  Channels together. This is called 'Etherchannel' by Cisco,
-	  'Trunking' by Sun, and 'Bonding' in Linux.
+	  'Trunking' by Sun, 802.3ad by the IEEE, and 'Bonding' in Linux.

-	  If you have two Ethernet connections to some other computer, you can
-	  make them behave like one double speed connection using this driver.
-	  Naturally, this has to be supported at the other end as well, either
-	  with a similar Bonding Linux driver, a Cisco 5500 switch or a
-	  SunTrunking SunSoft driver.
-
-	  This is similar to the EQL driver, but it merges Ethernet segments
-	  instead of serial lines.
+	  The driver supports multiple bonding modes to allow for both high
+	  perfomance and high availability operation.
+
+	  Refer to <file:Documentation/networking/bonding.txt> for more
+	  information.

 	  To compile this driver as a module, choose M here: the module
 	  will be called bonding.
