From: Xose Vazquez Perez <xose@wanadoo.es>
Subject: [PATCH ] more RTL-8139 clone boards
Date: Sun, 22 Feb 2004 16:26:32 +0100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <4038CA28.1080500@wanadoo.es>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------040005010207010208050005"
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com, jgarzik@pobox.com, marcelo.tosatti@cyclades.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------040005010207010208050005
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit


This patch already is in 2.6.

0x018A 0x0106 LevelOne FPC-0106TX
0x126C 0x1211 Nortel Networks 10/100BaseTX
0x1743 0x8139 Peppercon AG ROL-F
0x021B 0x8139 Compaq HNE-300

--------------040005010207010208050005
Content-Type: text/plain;
 name="8139too_idents.diff"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="8139too_idents.diff"

--- linux/drivers/net/8139too.c	2004-02-05 23:00:12.000000000 +0100
+++ n/drivers/net/8139too.c	2004-02-22 16:23:27.000000000 +0100
@@ -255,6 +255,10 @@
 	{0x11db, 0x1234, PCI_ANY_ID, PCI_ANY_ID, 0, 0, RTL8139 },
 	{0x1432, 0x9130, PCI_ANY_ID, PCI_ANY_ID, 0, 0, RTL8139 },
 	{0x02ac, 0x1012, PCI_ANY_ID, PCI_ANY_ID, 0, 0, RTL8139 },
+	{0x018a, 0x0106, PCI_ANY_ID, PCI_ANY_ID, 0, 0, RTL8139 },
+	{0x126c, 0x1211, PCI_ANY_ID, PCI_ANY_ID, 0, 0, RTL8139 },
+	{0x1743, 0x8139, PCI_ANY_ID, PCI_ANY_ID, 0, 0, RTL8139 },
+	{0x021b, 0x8139, PCI_ANY_ID, PCI_ANY_ID, 0, 0, RTL8139 },
 
 #ifdef CONFIG_SH_SECUREEDGE5410
 	/* Bogus 8139 silicon reports 8129 without external PROM :-( */

--------------040005010207010208050005--
