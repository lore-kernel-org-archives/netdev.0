From: Xose Vazquez Perez <xose@wanadoo.es>
Subject: [PATCH] 3c59x.c pci.ids
Date: Wed, 03 Sep 2003 14:31:23 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <3F55DF1B.4000105@wanadoo.es>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------070505010203050702040707"
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com, jgarzik <jgarzik@pobox.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------070505010203050702040707
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit

hi,

In 2.4.23-pre2 two pci.ids are missing  and there is one duplicate.
2.6.0-preX driver is ok.

-thanks-
-- 
Que trabajen los romanos, que tienen el pecho de lata.

--------------070505010203050702040707
Content-Type: text/plain;
 name="3c59x.diff"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="3c59x.diff"

--- linux/drivers/net/3c59x.c	2003-08-30 19:04:12.000000000 +0200
+++ linux.new/drivers/net/3c59x.c	2003-09-02 03:25:44.000000000 +0200
@@ -429,7 +429,6 @@
 	CH_3C905B_2,
 	CH_3C905B_FX,
 	CH_3C905C,
-	CH_3C905C2,
 	CH_3C980,
 	CH_3C9805,
 
@@ -450,6 +449,9 @@
 	CH_3C920,
 	CH_3C982A,
 	CH_3C982B,
+
+	CH_905BT4,
+	CH_920B_EMB_WNM,
 };
 
 
@@ -503,8 +505,6 @@
 	 PCI_USES_IO|PCI_USES_MASTER, IS_CYCLONE|HAS_HWCKSM, 128, },
 	{"3c905C Tornado",
 	 PCI_USES_IO|PCI_USES_MASTER, IS_TORNADO|HAS_NWAY|HAS_HWCKSM, 128, },
-	{"3c905C Tornado 2",
-	 PCI_USES_IO|PCI_USES_MASTER, IS_TORNADO|HAS_NWAY|HAS_HWCKSM, 128, },
 	{"3c980 Cyclone",
 	 PCI_USES_IO|PCI_USES_MASTER, IS_CYCLONE|HAS_HWCKSM, 128, },
 	{"3c980C Python-T",
@@ -550,6 +550,11 @@
 	{"3c982 Hydra Dual Port B",
 	 PCI_USES_IO|PCI_USES_MASTER, IS_TORNADO|HAS_HWCKSM|HAS_NWAY, 128, },
 
+	{"3c905B-T4",
+	 PCI_USES_IO|PCI_USES_MASTER, IS_CYCLONE|HAS_NWAY|HAS_HWCKSM, 128, },
+	{"3c920B-EMB-WNM Tornado",
+	 PCI_USES_IO|PCI_USES_MASTER, IS_TORNADO|HAS_NWAY|HAS_HWCKSM, 128, },
+
 	{0,}, /* 0 terminated list. */
 };
 
@@ -576,7 +581,6 @@
 	{ 0x10B7, 0x9058, PCI_ANY_ID, PCI_ANY_ID, 0, 0, CH_3C905B_2 },
 	{ 0x10B7, 0x905A, PCI_ANY_ID, PCI_ANY_ID, 0, 0, CH_3C905B_FX },
 	{ 0x10B7, 0x9200, PCI_ANY_ID, PCI_ANY_ID, 0, 0, CH_3C905C },
-	{ 0x10B7, 0x9201, PCI_ANY_ID, PCI_ANY_ID, 0, 0, CH_3C905C2 },
 	{ 0x10B7, 0x9800, PCI_ANY_ID, PCI_ANY_ID, 0, 0, CH_3C980 },
 	{ 0x10B7, 0x9805, PCI_ANY_ID, PCI_ANY_ID, 0, 0, CH_3C9805 },
 
@@ -597,6 +601,10 @@
 	{ 0x10B7, 0x9201, PCI_ANY_ID, PCI_ANY_ID, 0, 0, CH_3C920 },
 	{ 0x10B7, 0x1201, PCI_ANY_ID, PCI_ANY_ID, 0, 0, CH_3C982A },
 	{ 0x10B7, 0x1202, PCI_ANY_ID, PCI_ANY_ID, 0, 0, CH_3C982B },
+
+	{ 0x10B7, 0x9056, PCI_ANY_ID, PCI_ANY_ID, 0, 0, CH_905BT4 },
+	{ 0x10B7, 0x9210, PCI_ANY_ID, PCI_ANY_ID, 0, 0, CH_920B_EMB_WNM },
+
 	{0,}						/* 0 terminated list. */
 };
 MODULE_DEVICE_TABLE(pci, vortex_pci_tbl);

--------------070505010203050702040707--
