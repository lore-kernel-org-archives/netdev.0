From: margitsw@t-online.de (Margit Schubert-While)
Subject: [PATCH 4/6 Linux-2.6.7-bk13] prism54 device list cleanup
Date: Wed, 30 Jun 2004 19:41:19 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200406301941.19873.margitsw@t-online.de>
Mime-Version: 1.0
Content-Type: Multipart/Mixed;
  boundary="Boundary-00=_/sv4AYaDFFrlNJz"
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: jgarzik@pobox.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


--Boundary-00=_/sv4AYaDFFrlNJz
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

2004-06-28 Margit Schubert-While <margitsw@t-online.de>

* Clean up the device table

--Boundary-00=_/sv4AYaDFFrlNJz
Content-Type: text/x-diff;
  charset="us-ascii";
  name="04_pci_devices.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
	filename="04_pci_devices.patch"

diff -Naur linux-2.6.7-01/drivers/net/wireless/prism54/islpci_hotplug.c linux-2.6.7-02/drivers/net/wireless/prism54/islpci_hotplug.c
--- linux-2.6.7-01/drivers/net/wireless/prism54/islpci_hotplug.c	2004-06-25 19:48:40.000000000 +0200
+++ linux-2.6.7-02/drivers/net/wireless/prism54/islpci_hotplug.c	2004-06-25 20:14:46.000000000 +0200
@@ -38,81 +38,111 @@
 
 /* In this order: vendor, device, subvendor, subdevice, class, class_mask,
  * driver_data 
- * Note: for driver_data we put the device's name 
  * If you have an update for this please contact prism54-devel@prism54.org 
  * The latest list can be found at http://prism54.org/supported_cards.php */
 static const struct pci_device_id prism54_id_tbl[] = {
+	/* 3COM 3CRWE154G72 Wireless LAN adapter */
 	{
 	 PCIVENDOR_3COM, PCIDEVICE_3COM6001,
 	 PCIVENDOR_3COM, PCIDEVICE_3COM6001,
-	 0, 0,
-	 (unsigned long) "3COM 3CRWE154G72 Wireless LAN adapter"},
+	 0, 0, 0
+	},
+
+	/* D-Link Air Plus Xtreme G A1 - DWL-g650 A1 */
 	{
 	 PCIVENDOR_INTERSIL, PCIDEVICE_ISL3890,
 	 PCIVENDOR_DLINK, 0x3202UL, 
-	 0, 0,
-	 (unsigned long) "D-Link Air Plus Xtreme G A1 - DWL-g650 A1"},
+	 0, 0, 0
+	},
+
+	/* I-O Data WN-G54/CB - WN-G54/CB */
 	{
 	 PCIVENDOR_INTERSIL, PCIDEVICE_ISL3890,
 	 PCIVENDOR_IODATA, 0xd019UL, 
-	 0, 0,
-	 (unsigned long) "I-O Data WN-G54/CB - WN-G54/CB"},
+	 0, 0, 0
+	},
+
+	/* Netgear WG511 */
 	{
 	 PCIVENDOR_INTERSIL, PCIDEVICE_ISL3890,
 	 PCIVENDOR_NETGEAR, 0x4800UL,
-	 0, 0,
-	 (unsigned long) "Netgear WG511"},
+	 0, 0, 0
+	},
+
+	/* Tekram Technology clones, Allnet, Netcomm, Zyxel */
 	{
 	 PCIVENDOR_INTERSIL, PCIDEVICE_ISL3890,
-	 PCIVENDOR_I4, 0x0020UL,
-	 0, 0,
-	 (unsigned long) "PLANEX GW-DS54G"},
+	 PCIVENDOR_TTL, 0x1605UL,
+	 0, 0, 0
+	},
+
+	/* SMC2802W */
 	{
 	 PCIVENDOR_INTERSIL, PCIDEVICE_ISL3890,
 	 PCIVENDOR_SMC, 0x2802UL,
-	 0, 0,
-	 (unsigned long) "EZ Connect g 2.4GHz 54 Mbps Wireless PCI Card - SMC2802W"},
+	 0, 0, 0
+	},
+
+	/* SMC2835W */
 	{
 	 PCIVENDOR_INTERSIL, PCIDEVICE_ISL3890,
 	 PCIVENDOR_SMC, 0x2835UL,
-	 0, 0,
-	 (unsigned long) "EZ Connect g 2.4GHz 54 Mbps Wireless Cardbus Adapter - SMC2835W"},
+	 0, 0, 0
+	},
+
+	/* Corega CG-WLCB54GT */
 	{
 	 PCIVENDOR_INTERSIL, PCIDEVICE_ISL3890,
-	 PCIVENDOR_INTERSIL, 0x0000UL, /* This was probably a bogus reading... */
-	 0, 0,
-	 (unsigned long) "SparkLAN WL-850F"},
+	 PCIVENDOR_ATI, 0xc104UL,
+	 0, 0, 0
+	},
+
+	/* I4 Z-Com XG-600 */
 	{
 	 PCIVENDOR_INTERSIL, PCIDEVICE_ISL3890,
 	 PCIVENDOR_I4, 0x0014UL,
-	 0, 0,
-	 (unsigned long) "I4 Z-Com XG-600"},
+	 0, 0, 0
+	},
+
+	/* I4 Z-Com XG-900  and clones Macer, Ovislink, Planex, Peabird, */
+	/* Sitecom, Xterasys */
 	{
 	 PCIVENDOR_INTERSIL, PCIDEVICE_ISL3890,
 	 PCIVENDOR_I4, 0x0020UL,
-	 0, 0,
-	 (unsigned long) "I4 Z-Com XG-900/PLANEX GW-DS54G"},
+	 0, 0, 0
+	},
+
+	/* SMC 2802W V2 */
 	{
 	 PCIVENDOR_INTERSIL, PCIDEVICE_ISL3890,
 	 PCIVENDOR_ACCTON, 0xee03UL,
-	 0, 0,
-	 (unsigned long) "SMC 2802Wv2"},
+	 0, 0, 0
+	},
+
+	/* SMC 2835W V2 */
 	{
 	 PCIVENDOR_INTERSIL, PCIDEVICE_ISL3890,
 	 PCIVENDOR_SMC, 0xa835UL,
-	 0, 0,
-	 (unsigned long) "SMC 2835Wv2"},
+	 0, 0, 0
+	},
+
+	/* Intersil PRISM Indigo Wireless LAN adapter */
 	{
 	 PCIVENDOR_INTERSIL, PCIDEVICE_ISL3877,
 	 PCI_ANY_ID, PCI_ANY_ID,
-	 0, 0,
-	 (unsigned long) "Intersil PRISM Indigo Wireless LAN adapter"},
-	{ /* Default */
+	 0, 0, 0
+	},
+
+	/* Intersil PRISM Duette/Prism GT Wireless LAN adapter */
+	/* Default */
+	{
 	 PCIVENDOR_INTERSIL, PCIDEVICE_ISL3890,
 	 PCI_ANY_ID, PCI_ANY_ID,
-	 0, 0,
-	 (unsigned long) "Intersil PRISM Duette/Prism GT Wireless LAN adapter"},
-	{0,}
+	 0, 0, 0
+	},
+
+	/* End of list */
+	{0,0,0,0,0,0,0}
 };
 
 /* register the device with the Hotplug facilities of the kernel */
@@ -138,12 +168,16 @@
 {
 	islpci_private	*priv;
 	char		*modelp;
+	int		notwork = 0;
 
 	priv = netdev_priv(ndev);
 	switch (priv->pdev->subsystem_device) {
 	case PCIDEVICE_ISL3877:
 		modelp = "PRISM Indigo";
 		break;
+	case PCIDEVICE_ISL3886:
+		modelp = "PRISM Javelin / Xbow";
+		break;
 	case PCIDEVICE_3COM6001:
 		modelp = "3COM 3CRWE154G72";
 		break;
@@ -161,12 +195,20 @@
 		break;
 	case 0xee03UL:
 		modelp = "SMC2802W V2";
+		notwork = 1;
 		break;
 	case 0x2835UL:
 		modelp = "SMC2835W";
 		break;
 	case 0xa835UL:
 		modelp = "SMC2835W V2";
+		notwork = 1;
+		break;
+	case 0xc104UL:
+		modelp = "CG-WLCB54GT";
+		break;
+	case 0x1605UL:
+		modelp = "Tekram Technology clone";
 		break;
 	/* Let's leave this one out for now since it seems bogus/wrong 
 	 * Even if the manufacturer did use 0x0000UL it may not be correct
@@ -177,10 +219,10 @@
 
 	/* We have two reported for the one below :( */
 	case 0x0014UL:
-		modelp = "XG-600";
+		modelp = "I4 Z-Com XG-600 and clones";
 		break;
 	case 0x0020UL:
-		modelp = "XG-900/GW-DS54G";
+		modelp = "I4 Z-Com XG-900 and clones";
 		break;
 /* Default it */
 /*
@@ -193,6 +235,10 @@
 	}
 	printk(KERN_DEBUG "%s: %s driver detected card model: %s\n",
 			ndev->name, DRV_NAME, modelp);
+	if ( notwork ) {
+		printk(KERN_DEBUG "%s: %s Warning - This may not work\n",
+			ndev->name, DRV_NAME);
+	}
 	return;
 }
 
diff -Naur linux-2.6.7-01/drivers/net/wireless/prism54/islpci_mgt.h linux-2.6.7-02/drivers/net/wireless/prism54/islpci_mgt.h
--- linux-2.6.7-01/drivers/net/wireless/prism54/islpci_mgt.h	2004-06-25 19:48:40.000000000 +0200
+++ linux-2.6.7-02/drivers/net/wireless/prism54/islpci_mgt.h	2004-06-25 20:14:46.000000000 +0200
@@ -46,8 +46,11 @@
 #define PCIVENDOR_NETGEAR			0x1385UL
 #define PCIVENDOR_SMC				0x10b8UL
 #define PCIVENDOR_ACCTON			0x1113UL
+#define PCIVENDOR_ATI				0x1259UL
+#define PCIVENDOR_TTL				0x16a5UL
 
 #define PCIDEVICE_ISL3877                       0x3877UL
+#define PCIDEVICE_ISL3886                       0x3886UL
 #define PCIDEVICE_ISL3890                       0x3890UL
 #define	PCIDEVICE_3COM6001			0x6001UL
 #define PCIDEVICE_LATENCY_TIMER_MIN 		0x40

--Boundary-00=_/sv4AYaDFFrlNJz--
