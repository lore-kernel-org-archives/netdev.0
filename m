From: Xose Vazquez Perez <xose@wanadoo.es>
Subject: [PATCH] tg3, more IDs
Date: Sat, 06 Dec 2003 17:49:25 +0100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <3FD20895.2020605@wanadoo.es>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------050809000102050606080308"
Return-path: <netdev-bounce@oss.sgi.com>
To: Jeff Garzik <jgarzik@pobox.com>, netdev@oss.sgi.com,
        "David S. Miller"
 <davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------050809000102050606080308
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit

hi,

two new IDs for tg3:

0x14e4,0x1649 is a BCM5704S based board.
0x14e4,0x166e is a BCM5705F based board.

-thanks-


--------------050809000102050606080308
Content-Type: text/plain;
 name="tg3_ids.diff"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="tg3_ids.diff"

--- linux/drivers/net/tg3.c	2003-11-29 00:00:15.000000000 +0100
+++ n/drivers/net/tg3.c	2003-12-06 17:26:24.000000000 +0100
@@ -175,6 +175,10 @@
 	  PCI_ANY_ID, PCI_ANY_ID, 0, 0, 0UL },
 	{ PCI_VENDOR_ID_BROADCOM, PCI_DEVICE_ID_TIGON3_5901_2,
 	  PCI_ANY_ID, PCI_ANY_ID, 0, 0, 0UL },
+	{ PCI_VENDOR_ID_BROADCOM, PCI_DEVICE_ID_TIGON3_5704S_2,
+	  PCI_ANY_ID, PCI_ANY_ID, 0, 0, 0UL },
+	{ PCI_VENDOR_ID_BROADCOM, PCI_DEVICE_ID_TIGON3_5705F,
+	  PCI_ANY_ID, PCI_ANY_ID, 0, 0, 0UL },
 	{ PCI_VENDOR_ID_SYSKONNECT, PCI_DEVICE_ID_SYSKONNECT_9DXX,
 	  PCI_ANY_ID, PCI_ANY_ID, 0, 0, 0UL },
 	{ PCI_VENDOR_ID_SYSKONNECT, PCI_DEVICE_ID_SYSKONNECT_9MXX,
--- linux/include/linux/pci_ids.h	2003-11-29 00:00:21.000000000 +0100
+++ n/include/linux/pci_ids.h	2003-12-06 17:30:10.000000000 +0100
@@ -1656,11 +1656,13 @@
 #define PCI_DEVICE_ID_TIGON3_5702	0x1646
 #define PCI_DEVICE_ID_TIGON3_5703	0x1647
 #define PCI_DEVICE_ID_TIGON3_5704	0x1648
+#define PCI_DEVICE_ID_TIGON3_5704S_2	0x1649
 #define PCI_DEVICE_ID_TIGON3_5702FE	0x164d
 #define PCI_DEVICE_ID_TIGON3_5705	0x1653
 #define PCI_DEVICE_ID_TIGON3_5705_2	0x1654
 #define PCI_DEVICE_ID_TIGON3_5705M	0x165d
 #define PCI_DEVICE_ID_TIGON3_5705M_2	0x165e
+#define PCI_DEVICE_ID_TIGON3_5705F	0x166e
 #define PCI_DEVICE_ID_TIGON3_5782	0x1696
 #define PCI_DEVICE_ID_TIGON3_5788	0x169c
 #define PCI_DEVICE_ID_TIGON3_5702X	0x16a6


--------------050809000102050606080308--
