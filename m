From: Xose Vazquez Perez <xose@wanadoo.es>
Subject: [PATCH] detailled bcm help - 2.6.3
Date: Mon, 23 Feb 2004 14:33:17 +0100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <403A011D.1050909@wanadoo.es>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------050307040908070904040101"
Return-path: <netdev-bounce@oss.sgi.com>
To: jgarzik@redhat.com, Andrew Morton <akpm@osdl.org>, netdev@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------050307040908070904040101
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit


This patch adds more realistic information about bcm NICs.
People only know the commercial names and not about chips names.

-- 
x86-64 GenuineIntel


--------------050307040908070904040101
Content-Type: text/plain;
 name="bcm-help.diff"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="bcm-help.diff"

--- linux-2.6.2/drivers/net/Kconfig	2004-02-20 14:39:40.000000000 +0100
+++ n/drivers/net/Kconfig	2004-02-23 14:17:23.000000000 +0100
@@ -1275,9 +1275,7 @@
 	tristate "Broadcom 4400 ethernet support (EXPERIMENTAL)"
 	depends on NET_PCI && PCI && EXPERIMENTAL
 	help
-	  If you have a network (Ethernet) controller of this type, say Y and
-	  read the Ethernet-HOWTO, available from
-	  <http://www.tldp.org/docs.html#howto>.
+	  This driver supports Broadcom BCM440X based 10/100 Ethernet cards.
 
 	  To compile this driver as a module, choose M here and read
 	  <file:Documentation/networking/net-modules.txt>.  The module will be
@@ -2056,7 +2054,7 @@
 	tristate "Broadcom Tigon3 support"
 	depends on PCI
 	help
-	  This driver supports Broadcom Tigon3 based gigabit Ethernet cards.
+	  This driver supports Broadcom NetXtreme BCM570X based gigabit Ethernet cards.
 
 	  To compile this driver as a module, choose M here: the module
 	  will be called tg3.  This is recommended.


--------------050307040908070904040101--
