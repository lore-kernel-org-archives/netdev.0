From: Francois Romieu <romieu@fr.zoreil.com>
Subject: [patch 2.6.12-rc2-mm3 1/1] r8169: new PCI id
Date: Mon, 11 Apr 2005 23:55:11 +0200
Message-ID: <20050411215511.GA2819@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: jgarzik@pobox.com, TommyDrum <mycooc@yahoo.it>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: akpm@osdl.org
Content-Disposition: inline
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

The USR 997902 is based on the 8169 chipset.

The value has been extracted from the sources of the driver which
comes with the manufacturer's cdrom. Heads-up and test by TommyDrum
<mycooc@yahoo.it>.

Signed-off-by: Francois Romieu <romieu@fr.zoreil.com>

diff -puN drivers/net/r8169.c~r8169-610 drivers/net/r8169.c
--- a/drivers/net/r8169.c~r8169-610	2005-04-11 23:00:42.732205462 +0200
+++ b/drivers/net/r8169.c	2005-04-11 23:01:11.372565356 +0200
@@ -176,6 +176,7 @@ const static struct {
 static struct pci_device_id rtl8169_pci_tbl[] = {
 	{0x10ec, 0x8169, PCI_ANY_ID, PCI_ANY_ID, 0, 0, 0},
 	{0x1186, 0x4300, PCI_ANY_ID, PCI_ANY_ID, 0, 0, 0},
+	{0x16ec, 0x0116, PCI_ANY_ID, PCI_ANY_ID, 0, 0, 0},
 	{0,},
 };
 

_
