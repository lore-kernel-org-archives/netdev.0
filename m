From: Francois Romieu <romieu@fr.zoreil.com>
Subject: [patch 2.6.11-rc4-netdev1 5/5] r8169: literate PCI ID
Date: Tue, 22 Feb 2005 00:58:34 +0100
Message-ID: <20050221235834.GE31723@electric-eye.fr.zoreil.com>
References: <20050221235125.GD26248@electric-eye.fr.zoreil.com> <20050221235301.GA31723@electric-eye.fr.zoreil.com> <20050221235450.GB31723@electric-eye.fr.zoreil.com> <20050221235611.GC31723@electric-eye.fr.zoreil.com> <20050221235718.GD31723@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com, jdmason@us.ibm.com
To: Jeff Garzik <jgarzik@pobox.com>
Content-Disposition: inline
In-Reply-To: <20050221235718.GD31723@electric-eye.fr.zoreil.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

De-obfuscate supported PCI ID

Non-hackers happen to read the sources too.

Signed-off-by: Francois Romieu <romieu@fr.zoreil.com>

diff -puN drivers/net/r8169.c~r8169-440 drivers/net/r8169.c
--- a/drivers/net/r8169.c~r8169-440	2005-02-21 23:42:21.193570455 +0100
+++ b/drivers/net/r8169.c	2005-02-21 23:42:21.200569312 +0100
@@ -174,8 +174,10 @@ const static struct {
 #undef _R
 
 static struct pci_device_id rtl8169_pci_tbl[] = {
-	{0x10ec, 0x8169, PCI_ANY_ID, PCI_ANY_ID, 0, 0, 0},
-	{0x1186, 0x4300, PCI_ANY_ID, PCI_ANY_ID, 0, 0, 0},
+	{ PCI_VENDOR_ID_REALTEK, PCI_DEVICE_ID_REALTEK_8169,
+	  PCI_ANY_ID, PCI_ANY_ID, 0, 0, 0UL },
+	{ PCI_VENDOR_ID_DLINK, PCI_DEVICE_ID_DLINK_DGE528T,
+	  PCI_ANY_ID, PCI_ANY_ID, 0, 0, 0UL },
 	{0,},
 };
 
diff -puN include/linux/pci_ids.h~r8169-440 include/linux/pci_ids.h
--- a/include/linux/pci_ids.h~r8169-440	2005-02-21 23:42:21.196569965 +0100
+++ b/include/linux/pci_ids.h	2005-02-21 23:42:21.204568659 +0100
@@ -1485,6 +1485,7 @@
 
 #define PCI_VENDOR_ID_DLINK		0x1186
 #define PCI_DEVICE_ID_DLINK_DGE510T	0x4c00
+#define PCI_DEVICE_ID_DLINK_DGE528T	0x4300
 
 #define PCI_VENDOR_ID_ARTOP		0x1191
 #define PCI_DEVICE_ID_ARTOP_ATP8400	0x0004

_
