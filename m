From: Xose Vazquez Perez <xose@wanadoo.es>
Subject: [PATCH ] more eepro100 boards
Date: Tue, 18 Nov 2003 23:06:28 +0100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <3FBA97E4.1060004@wanadoo.es>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------010307050302050103040800"
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com, jgarzik@pobox.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------010307050302050103040800
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit


deleted PCI_DEVICE_ID_INTEL_82801BA_7, it's a  duplicate of 0x2449

and added five boards:

0x1051
0x1052
0x1053
0x1054
0x1055


These should be deleted:

0x1035
0x1036
0x1037
0x1227
0x1228
0x5200
0x5201

Time ago, in conversation with some intel guys, they said me that
those boards are not compatibles with the driver.  Do anyone run
eepro100 with any of those boards?

-thanks-

--------------010307050302050103040800
Content-Type: text/plain;
 name="eepro100_idents.diff"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="eepro100_idents.diff"

--- linux/drivers/net/eepro100.c	2003-08-27 17:26:41.000000000 +0200
+++ new/drivers/net/eepro100.c	2003-11-18 22:10:32.000000000 +0100
@@ -2374,8 +2374,6 @@
 		PCI_ANY_ID, PCI_ANY_ID, },
 	{ PCI_VENDOR_ID_INTEL, PCI_DEVICE_ID_INTEL_82559ER,
 		PCI_ANY_ID, PCI_ANY_ID, },
-	{ PCI_VENDOR_ID_INTEL, PCI_DEVICE_ID_INTEL_82801BA_7,
-		PCI_ANY_ID, PCI_ANY_ID, },
 	{ PCI_VENDOR_ID_INTEL, 0x1029, PCI_ANY_ID, PCI_ANY_ID, },
 	{ PCI_VENDOR_ID_INTEL, 0x1030, PCI_ANY_ID, PCI_ANY_ID, },
 	{ PCI_VENDOR_ID_INTEL, 0x1031, PCI_ANY_ID, PCI_ANY_ID, },
@@ -2393,6 +2391,11 @@
 	{ PCI_VENDOR_ID_INTEL, 0x103D, PCI_ANY_ID, PCI_ANY_ID, },
 	{ PCI_VENDOR_ID_INTEL, 0x103E, PCI_ANY_ID, PCI_ANY_ID, },
 	{ PCI_VENDOR_ID_INTEL, 0x1050, PCI_ANY_ID, PCI_ANY_ID, },
+	{ PCI_VENDOR_ID_INTEL, 0x1051, PCI_ANY_ID, PCI_ANY_ID, },
+	{ PCI_VENDOR_ID_INTEL, 0x1052, PCI_ANY_ID, PCI_ANY_ID, },
+	{ PCI_VENDOR_ID_INTEL, 0x1053, PCI_ANY_ID, PCI_ANY_ID, },
+	{ PCI_VENDOR_ID_INTEL, 0x1054, PCI_ANY_ID, PCI_ANY_ID, },
+	{ PCI_VENDOR_ID_INTEL, 0x1055, PCI_ANY_ID, PCI_ANY_ID, },
 	{ PCI_VENDOR_ID_INTEL, 0x1059, PCI_ANY_ID, PCI_ANY_ID, },
 	{ PCI_VENDOR_ID_INTEL, 0x1227, PCI_ANY_ID, PCI_ANY_ID, },
 	{ PCI_VENDOR_ID_INTEL, 0x1228, PCI_ANY_ID, PCI_ANY_ID, },


--------------010307050302050103040800--
