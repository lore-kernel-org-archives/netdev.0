From: Xose Vazquez Perez <xose@wanadoo.es>
Subject: deleting pci.ids
Date: Mon, 22 Dec 2003 20:25:13 +0100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <3FE74519.2060802@wanadoo.es>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Return-path: <netdev-bounce@oss.sgi.com>
To: Tosatti <marcelo.tosatti@cyclades.com>, Jeff Garzik
 <jgarzik@pobox.com>,
        netdev@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

hi,

why is this patch deleting two TIGON_3 ids ?

-	4400 SK-9Dxx Gigabit Ethernet Adapter
-	4500 SK-9Mxx Gigabit Ethernet Adapter

http://kernel.org/pub/linux/kernel/v2.4/testing/cset/cset-mlindner@syskonnect.de|ChangeSet|20031216043546|60164.txt

# The following is the BitKeeper ChangeSet Log
# --------------------------------------------
# 03/12/15	mlindner@syskonnect.de	1.1136.73.11
# [PATCH] sk98lin-2.4: pci.ids Update to Driver Version v6.21
#
# Patch 4/4 (Update to version 6.21)
# * Add: Update of the PCI Vendors list
# --------------------------------------------
#
diff -Nru a/drivers/pci/pci.ids b/drivers/pci/pci.ids
--- a/drivers/pci/pci.ids	Mon Dec 22 11:04:55 2003
+++ b/drivers/pci/pci.ids	Mon Dec 22 11:04:55 2003
@@ -3428,8 +3428,6 @@
 		1148 5061  SK-9861 V2.0 Gigabit Ethernet 1000Base-SX Adapter
 		1148 5071  SK-9871 V2.0 Gigabit Ethernet 1000Base-ZX Adapter
 		1148 9521  SK-9521 10/100/1000Base-T Adapter
-	4400 SK-9Dxx Gigabit Ethernet Adapter
-	4500 SK-9Mxx Gigabit Ethernet Adapter
 1149  Win System Corporation
 114a  VMIC
 	5579  VMIPCI-5579 (Reflective Memory Card)
@@ -3727,7 +3725,22 @@
 	0146  GT-64010/64010A System Controller
 	4146  GT-64011/GT-64111 System Controller
 	4320  Gigabit Ethernet Adapter
-		11ab 9521  Marvell Yukon Gigabit Ethernet 10/100/1000Base-T Adapter
+		1019 0f38  Marvell 88E8001 Gigabit LOM Ethernet Adapter (ECS)
+		1019 8001  Marvell 88E8001 Gigabit LOM Ethernet Adapter (ECS)
+		1043 173c  Marvell 88E8001 Gigabit LOM Ethernet Adapter (Asus)
+		1043 811a  Marvell 88E8001 Gigabit LOM Ethernet Adapter (Asus)
+		105b 0c19  Marvell 88E8001 Gigabit LOM Ethernet Adapter (Foxconn)
+		10b8 b452  SMC EZ Card 1000 (SMC9452TXV.2)
+		11ab 0121  Marvell RDK-8001 Adapter
+		11ab 0321  Marvell RDK-8003 Adapter
+		11ab 1021  Marvell RDK-8010 Adapter
+		11ab 5021  Marvell Yukon Gigabit Ethernet 10/100/1000Base-T Adapter (64 bit)
+		11ab 9521  Marvell Yukon Gigabit Ethernet 10/100/1000Base-T Adapter (32 bit)
+		1458 e000  Marvell 88E8001 Gigabit LOM Ethernet Adapter (Gigabyte)
+		147b 1406  Marvell 88E8001 Gigabit LOM Ethernet Adapter (Abit)
+		15d4 0047  Marvell 88E8001 Gigabit LOM Ethernet Adapter (Iwill)
+		1695 9025  Marvell 88E8001 Gigabit LOM Ethernet Adapter (Epox)
+		17f2 1c03  Marvell 88E8001 Gigabit LOM Ethernet Adapter (Albatron)
 	4611  GT-64115 System Controller
 	4620  GT-64120/64120A/64121A System Controller
 	4801  GT-48001

-thanks-
