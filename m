From: Francois Romieu <romieu@fr.zoreil.com>
Subject: [patch linux-2.6.12-rc3-mm3 1/7] r8169: de-obfuscate supported PCI ID
Date: Fri, 6 May 2005 00:56:56 +0200
Message-ID: <20050505225656.GA11200@electric-eye.fr.zoreil.com>
References: <20050504221057.1e02a402.akpm@osdl.org> <20050505115502.GA4414@electric-eye.fr.zoreil.com> <20050505110052.62c1c2cb.akpm@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com, jgarzik@pobox.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Andrew Morton <akpm@osdl.org>
Content-Disposition: inline
In-Reply-To: <20050505110052.62c1c2cb.akpm@osdl.org>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

De-obfuscate supported PCI ID

Signed-off-by: Francois Romieu <romieu@fr.zoreil.com>

diff -puN drivers/net/r8169.c~r8169-440 drivers/net/r8169.c
--- a/drivers/net/r8169.c~r8169-440	2005-05-06 00:37:16.695925125 +0200
+++ b/drivers/net/r8169.c	2005-05-06 00:38:40.051448306 +0200
@@ -174,9 +174,9 @@ const static struct {
 #undef _R
 
 static struct pci_device_id rtl8169_pci_tbl[] = {
-	{0x10ec, 0x8169, PCI_ANY_ID, PCI_ANY_ID, 0, 0, 0},
-	{0x1186, 0x4300, PCI_ANY_ID, PCI_ANY_ID, 0, 0, 0},
-	{0x16ec, 0x0116, PCI_ANY_ID, PCI_ANY_ID, 0, 0, 0},
+	{ PCI_DEVICE(PCI_VENDOR_ID_REALTEK,	0x8169), },
+	{ PCI_DEVICE(PCI_VENDOR_ID_DLINK,	0x4300), },
+	{ PCI_DEVICE(0x16ec,			0x0116), },
 	{0,},
 };
 

_
