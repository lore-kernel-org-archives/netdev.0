From: Bogdan Costescu <bogdan.costescu@iwr.uni-heidelberg.de>
Subject: [3c59x] Add support for ATI Radeon 9100 IGP
Date: Tue, 1 Jun 2004 18:48:57 +0200 (CEST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.4.44.0406011746340.32516-100000@kenzo.iwr.uni-heidelberg.de>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Andrew Morton <akpm@osdl.org>
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


Hi!

[ I don't know if Andrew (3c59x maintainer) still reads the vortex
mailing list where I just posted the same patch, so I thought
mentioning it on netdev as well would be a good idea. ]

The patch adds support for the 3Com networking core found in the ATI
Radeon 9100 IGP southbridge used on boards like Asus P4R800-VM. The
patch is against the 3c59x driver from 2.6.6; it should apply cleanly
to most other 2.6 versions and applies with some offsets also for
2.4.2x.

A bit of discussion about the patch can be found on the vortex list 
archives, like:

http://marc.theaimsgroup.com/?l=linux-vortex&m=108610754614149&w=2


--- linux-2.6.6-orig/drivers/net/3c59x.c	2004-05-10 04:31:55.000000000 +0200
+++ linux-2.6.6/drivers/net/3c59x.c	2004-05-25 23:45:29.000000000 +0200
@@ -446,6 +446,7 @@
 	CH_3C905B_2,
 	CH_3C905B_FX,
 	CH_3C905C,
+	CH_3C9202,
 	CH_3C980,
 	CH_3C9805,
 
@@ -521,6 +522,8 @@
 	 PCI_USES_IO|PCI_USES_MASTER, IS_CYCLONE|HAS_HWCKSM, 128, },
 	{"3c905C Tornado",
 	 PCI_USES_IO|PCI_USES_MASTER, IS_TORNADO|HAS_NWAY|HAS_HWCKSM, 128, },
+	{"3C920B-EMB-WNM (ATI Radeon 9100 IGP)",
+	 PCI_USES_IO|PCI_USES_MASTER, IS_TORNADO|HAS_MII|HAS_HWCKSM, 128, },
 	{"3c980 Cyclone",
 	 PCI_USES_IO|PCI_USES_MASTER, IS_CYCLONE|HAS_HWCKSM, 128, },
 	{"3c980C Python-T",
@@ -597,6 +600,7 @@
 	{ 0x10B7, 0x9058, PCI_ANY_ID, PCI_ANY_ID, 0, 0, CH_3C905B_2 },
 	{ 0x10B7, 0x905A, PCI_ANY_ID, PCI_ANY_ID, 0, 0, CH_3C905B_FX },
 	{ 0x10B7, 0x9200, PCI_ANY_ID, PCI_ANY_ID, 0, 0, CH_3C905C },
+	{ 0x10B7, 0x9202, PCI_ANY_ID, PCI_ANY_ID, 0, 0, CH_3C9202 },
 	{ 0x10B7, 0x9800, PCI_ANY_ID, PCI_ANY_ID, 0, 0, CH_3C980 },
 	{ 0x10B7, 0x9805, PCI_ANY_ID, PCI_ANY_ID, 0, 0, CH_3C9805 },
 

-- 
Bogdan Costescu

IWR - Interdisziplinaeres Zentrum fuer Wissenschaftliches Rechnen
Universitaet Heidelberg, INF 368, D-69120 Heidelberg, GERMANY
Telephone: +49 6221 54 8869, Telefax: +49 6221 54 8868
E-mail: Bogdan.Costescu@IWR.Uni-Heidelberg.De
