From: ravinandan.arakali@neterion.com
Subject: [KJ] [PATCH 2.6.12-rc1-bk1 3/3] S2io: Changed copyright and added
	support for Xframe II
Date: Tue, 29 Mar 2005 15:24:54 -0800 (PST)
Message-ID: <20050329232454.170575BB36@linux.site>
Content-Type: multipart/mixed; boundary="===============6508988533777218=="
Cc: raghavendra.koushik@neterion.com, ravinandan.arakali@neterion.com,
   leonid.grossman@neterion.com, rapuru.sriram@neterion.com
Return-path: <kernel-janitors-bounces@lists.osdl.org>
To: jgarzik@pobox.com, netdev@oss.sgi.com, kernel-janitors@lists.osdl.org
List-Unsubscribe: <http://lists.osdl.org/mailman/listinfo/kernel-janitors>,
	<mailto:kernel-janitors-request@lists.osdl.org?subject=unsubscribe>
List-Archive: <http://lists.osdl.org/pipermail/kernel-janitors>
List-Post: <mailto:kernel-janitors@lists.osdl.org>
List-Help: <mailto:kernel-janitors-request@lists.osdl.org?subject=help>
List-Subscribe: <http://lists.osdl.org/mailman/listinfo/kernel-janitors>,
	<mailto:kernel-janitors-request@lists.osdl.org?subject=subscribe>
Sender: kernel-janitors-bounces@lists.osdl.org
Errors-To: kernel-janitors-bounces@lists.osdl.org
List-Id: netdev.vger.kernel.org

--===============6508988533777218==

Hello,
Below patch includes the following:
 
1. Change of Copyright to reflect S2io's new name "Neterion Inc."
2. Updated driver version number.
3. Add an additional PCI device id to support Neterion's new Xframe II.

Some background info on Xframe-II, just in case - 

The NIC was announced back in January (see
http://www.serverwatch.com/news/article.php/3464871) 

Xframe II is a PCI-X 2.0 DDR adapter designed to work in PCI-X 2.0 servers
(it is also backwards compatible with current pci-x and pci slots); it's a
first card to overcome pci-x 133 throughput bottleneck. Some of these pci-x
2.0 servers are available now and more are coming later in the year.

Xframe II is completely backward compatible and hence the current driver
will work as-is, except the device id change.

There are some additional features/stateless offloads in Xframe-II 
as well; we plan to submit patches for these soon.
 
Thanks,
Ravi

Signed-off-by: Ravinandan Arakali <ravinandan.arakali@neterion.com>
---
diff -urN hwfixes2/drivers/net/s2io-regs.h copyright_xframeIIdevid3/drivers/net/s2io-regs.h
--- hwfixes2/drivers/net/s2io-regs.h	2005-03-25 07:05:47.000000000 -0800
+++ copyright_xframeIIdevid3/drivers/net/s2io-regs.h	2005-03-25 09:33:59.000000000 -0800
@@ -1,6 +1,6 @@
 /************************************************************************
  * regs.h: A Linux PCI-X Ethernet driver for S2IO 10GbE Server NIC
- * Copyright 2002 Raghavendra Koushik (raghavendra.koushik@s2io.com)
+ * Copyright(c) 2002-2005 Neterion Inc.
 
  * This software may be used and distributed according to the terms of
  * the GNU General Public License (GPL), incorporated herein by reference.
diff -urN hwfixes2/drivers/net/s2io.c copyright_xframeIIdevid3/drivers/net/s2io.c
--- hwfixes2/drivers/net/s2io.c	2005-03-25 08:37:33.000000000 -0800
+++ copyright_xframeIIdevid3/drivers/net/s2io.c	2005-03-25 09:59:38.000000000 -0800
@@ -1,6 +1,6 @@
 /************************************************************************
  * s2io.c: A Linux PCI-X Ethernet driver for S2IO 10GbE Server NIC
- * Copyright(c) 2002-2005 S2IO Technologies
+ * Copyright(c) 2002-2005 Neterion Inc.
 
  * This software may be used and distributed according to the terms of
  * the GNU General Public License (GPL), incorporated herein by reference.
@@ -66,7 +66,7 @@
 
 /* S2io Driver name & version. */
 static char s2io_driver_name[] = "s2io";
-static char s2io_driver_version[] = "Version 1.7.5.1";
+static char s2io_driver_version[] = "Version 1.7.7.1";
 
 /* 
  * Cards with following subsystem_id have a link state indication
@@ -245,6 +245,10 @@
 	 PCI_ANY_ID, PCI_ANY_ID},
 	{PCI_VENDOR_ID_S2IO, PCI_DEVICE_ID_S2IO_UNI,
 	 PCI_ANY_ID, PCI_ANY_ID},
+	{PCI_VENDOR_ID_S2IO, PCI_DEVICE_ID_HERC_WIN,
+	 PCI_ANY_ID, PCI_ANY_ID},
+	{PCI_VENDOR_ID_S2IO, PCI_DEVICE_ID_HERC_UNI,
+	 PCI_ANY_ID, PCI_ANY_ID},
 	{0,}
 };
 
@@ -4534,7 +4538,7 @@
 			     &(sp->pcix_cmd));
 }
 
-MODULE_AUTHOR("Raghavendra Koushik <raghavendra.koushik@s2io.com>");
+MODULE_AUTHOR("Raghavendra Koushik <raghavendra.koushik@neterion.com>");
 MODULE_LICENSE("GPL");
 module_param(tx_fifo_num, int, 0);
 module_param_array(tx_fifo_len, int, NULL, 0);
diff -urN hwfixes2/drivers/net/s2io.h copyright_xframeIIdevid3/drivers/net/s2io.h
--- hwfixes2/drivers/net/s2io.h	2005-03-28 07:16:29.000000000 -0800
+++ copyright_xframeIIdevid3/drivers/net/s2io.h	2005-03-28 07:20:44.000000000 -0800
@@ -1,6 +1,6 @@
 /************************************************************************
  * s2io.h: A Linux PCI-X Ethernet driver for S2IO 10GbE Server NIC
- * Copyright 2002 Raghavendra Koushik (raghavendra.koushik@s2io.com)
+ * Copyright(c) 2002-2005 Neterion Inc.
 
  * This software may be used and distributed according to the terms of
  * the GNU General Public License (GPL), incorporated herein by reference.
diff -urN hwfixes2/include/linux/pci_ids.h copyright_xframeIIdevid3/include/linux/pci_ids.h
--- hwfixes2/include/linux/pci_ids.h	2005-03-25 09:46:47.000000000 -0800
+++ copyright_xframeIIdevid3/include/linux/pci_ids.h	2005-03-25 09:48:58.000000000 -0800
@@ -2153,6 +2153,8 @@
 #define PCI_VENDOR_ID_S2IO		0x17d5
 #define	PCI_DEVICE_ID_S2IO_WIN		0x5731
 #define	PCI_DEVICE_ID_S2IO_UNI		0x5831
+#define PCI_DEVICE_ID_HERC_WIN		0x5732
+#define PCI_DEVICE_ID_HERC_UNI		0x5832
 
 #define PCI_VENDOR_ID_INFINICON		0x1820
 

--===============6508988533777218==
Content-Type: text/plain; charset="iso-8859-1"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable
Content-Disposition: inline

_______________________________________________
Kernel-janitors mailing list
Kernel-janitors@lists.osdl.org
http://lists.osdl.org/mailman/listinfo/kernel-janitors

--===============6508988533777218==--
