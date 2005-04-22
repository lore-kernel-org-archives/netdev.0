From: Ruud Linders <rkmp@xs4all.nl>
Subject: Patch for USR r8169 clone
Date: Fri, 22 Apr 2005 19:41:39 +0200
Message-ID: <42693753.7010907@xs4all.nl>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------020303020800050604020703"
Cc: romieu@fr.zoreil.com
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------020303020800050604020703
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit


Hello,

This patch makes my U.S.Robotics USR997902 gigabit ethernet card work.
Compiled and tested and working fine for me.

Please consider including in next update to r8169.c.

Thanks,
	Ruud Linders


--------------020303020800050604020703
Content-Type: text/plain;
 name="PATCH.r8169.c_for_USR997902"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="PATCH.r8169.c_for_USR997902"

--- r8169.c.ORIG	2004-12-25 11:36:12.000000000 +0100
+++ r8169.c	2005-04-22 19:18:12.000000000 +0200
@@ -151,6 +151,7 @@
 static struct pci_device_id rtl8169_pci_tbl[] = {
 	{0x10ec, 0x8169, PCI_ANY_ID, PCI_ANY_ID, 0, 0, 0},
 	{0x1186, 0x4300, PCI_ANY_ID, PCI_ANY_ID, 0, 0, 0},
+	{0x16EC, 0x0116, PCI_ANY_ID, PCI_ANY_ID, 0, 0, 0},
 	{0,},
 };
 

--------------020303020800050604020703--
