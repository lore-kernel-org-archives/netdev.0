From: ganesh.venkatesan@intel.com
Subject: [PATCH 2/6 2.5] e100 - Support for Intel(R) PRO/100 VE Network
 Connection
Date: Thu, 29 Jul 2004 08:33:32 -0700 (PDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.4.44.0407290648090.21929-100000@westville2.jf.intel.com>
Reply-To: ganesh.venkatesan@intel.com
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@oss.sgi.com, <ganesh.venkatesan@intel.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: jgarzik@pobox.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

--- linux-2.5/drivers/net/e100.c	2004-07-29 00:25:01.873679848 -0700
+++ linux-2.5/drivers/net/e100.c.mod	2004-07-29 00:26:04.553151120 -0700
@@ -201,6 +201,8 @@ static struct pci_device_id e100_id_tabl
 	INTEL_8255X_ETHERNET_DEVICE(0x1053, 5),
 	INTEL_8255X_ETHERNET_DEVICE(0x1054, 5),
 	INTEL_8255X_ETHERNET_DEVICE(0x1055, 5),
+	INTEL_8255X_ETHERNET_DEVICE(0x1056, 5),
+	INTEL_8255X_ETHERNET_DEVICE(0x1057, 5),
 	INTEL_8255X_ETHERNET_DEVICE(0x1064, 6),
 	INTEL_8255X_ETHERNET_DEVICE(0x1065, 6),
 	INTEL_8255X_ETHERNET_DEVICE(0x1066, 6),
@@ -242,6 +244,7 @@ enum phy {
 	phy_nsc_tx   = 0x5C002000,
 	phy_82562_et = 0x033002A8,
 	phy_82562_em = 0x032002A8,
+	phy_82562_ek = 0x031002A8,
 	phy_82562_eh = 0x017002A8,
 	phy_unknown  = 0xFFFFFFFF,
 };
@@ -1641,7 +1644,7 @@ static int e100_change_mtu(struct net_de
 static int e100_asf(struct nic *nic)
 {
 	/* ASF can be enabled from eeprom */
-	return((nic->pdev->device >= 0x1050) && (nic->pdev->device <= 0x1055) &&
+	return((nic->pdev->device >= 0x1050) && (nic->pdev->device <= 0x1057) &&
 	   (nic->eeprom[eeprom_config_asf] & eeprom_asf) &&
 	   !(nic->eeprom[eeprom_config_asf] & eeprom_gcl) &&
 	   ((nic->eeprom[eeprom_smbus_addr] & 0xFF) != 0xFE));
