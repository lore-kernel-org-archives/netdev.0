From: Xose Vazquez Perez <xose@wanadoo.es>
Subject: [PATCH ] more ne2k-pci clone boards
Date: Tue, 18 Nov 2003 21:48:54 +0100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <3FBA85B6.8010008@wanadoo.es>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------040005060409030706010906"
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com, jgarzik@pobox.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------040005060409030706010906
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit


0x8c4a 0x1980 Winbond W89C940(misprogrammed)

--
HTML mails are going to trash automagically


--------------040005060409030706010906
Content-Type: text/plain;
 name="ne2k-pci_idents.diff"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="ne2k-pci_idents.diff"

--- linux/drivers/net/ne2k-pci.c	2003-11-15 16:47:29.000000000 +0100
+++ new/drivers/net/ne2k-pci.c	2003-11-18 21:16:28.000000000 +0100
@@ -116,6 +116,7 @@
 	CH_Winbond_W89C940F,
 	CH_Holtek_HT80232,
 	CH_Holtek_HT80229,
+	CH_Winbond_89C940_8c4a,
 };
 
 
@@ -133,6 +134,7 @@
 	{"Winbond W89C940F", 0},
 	{"Holtek HT80232", ONLY_16BIT_IO | HOLTEK_FDX},
 	{"Holtek HT80229", ONLY_32BIT_IO | HOLTEK_FDX | STOP_PG_0x60 },
+	{"Winbond W89C940(misprogrammed)", 0},
 	{0,}
 };
 
@@ -148,6 +150,7 @@
 	{ 0x1050, 0x5a5a, PCI_ANY_ID, PCI_ANY_ID, 0, 0, CH_Winbond_W89C940F },
 	{ 0x12c3, 0x0058, PCI_ANY_ID, PCI_ANY_ID, 0, 0, CH_Holtek_HT80232 },
 	{ 0x12c3, 0x5598, PCI_ANY_ID, PCI_ANY_ID, 0, 0, CH_Holtek_HT80229 },
+	{ 0x8c4a, 0x1980, PCI_ANY_ID, PCI_ANY_ID, 0, 0, CH_Winbond_89C940_8c4a },
 	{ 0, }
 };
 MODULE_DEVICE_TABLE(pci, ne2k_pci_tbl);


--------------040005060409030706010906--
