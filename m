From: "Feldman, Scott" <scott.feldman@intel.com>
Subject: [e1000 netdev-2.6 6/6] Misc - copyright, changelog spelling
Date: Mon, 2 Feb 2004 14:02:15 -0800 (PST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.4.44.0402021359300.6288-100000@localhost.localdomain>
Reply-To: "Feldman, Scott" <scott.feldman@intel.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@oss.sgi.com, "Feldman, Scott" <scott.feldman@intel.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Jeff Garzik <jgarzik@pobox.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


* Misc - copyright update, changelog, spelling fixes.

--------------

diff -Naurp netdev-2.6/drivers/net/e1000/e1000_ethtool.c netdev-2.6/drivers/net/e1000.mod/e1000_ethtool.c
--- netdev-2.6/drivers/net/e1000/e1000_ethtool.c	2004-02-02 12:11:27.000000000 -0800
+++ netdev-2.6/drivers/net/e1000.mod/e1000_ethtool.c	2004-02-02 12:11:52.000000000 -0800
@@ -1,7 +1,7 @@
 /*******************************************************************************
 
   
-  Copyright(c) 1999 - 2003 Intel Corporation. All rights reserved.
+  Copyright(c) 1999 - 2004 Intel Corporation. All rights reserved.
   
   This program is free software; you can redistribute it and/or modify it 
   under the terms of the GNU General Public License as published by the Free 
diff -Naurp netdev-2.6/drivers/net/e1000/e1000.h netdev-2.6/drivers/net/e1000.mod/e1000.h
--- netdev-2.6/drivers/net/e1000/e1000.h	2004-02-02 12:11:27.000000000 -0800
+++ netdev-2.6/drivers/net/e1000.mod/e1000.h	2004-02-02 12:11:56.000000000 -0800
@@ -1,7 +1,7 @@
 /*******************************************************************************
 
   
-  Copyright(c) 1999 - 2003 Intel Corporation. All rights reserved.
+  Copyright(c) 1999 - 2004 Intel Corporation. All rights reserved.
   
   This program is free software; you can redistribute it and/or modify it 
   under the terms of the GNU General Public License as published by the Free 
diff -Naurp netdev-2.6/drivers/net/e1000/e1000_hw.c netdev-2.6/drivers/net/e1000.mod/e1000_hw.c
--- netdev-2.6/drivers/net/e1000/e1000_hw.c	2004-02-02 12:11:27.000000000 -0800
+++ netdev-2.6/drivers/net/e1000.mod/e1000_hw.c	2004-02-02 12:11:59.000000000 -0800
@@ -1,7 +1,7 @@
 /*******************************************************************************
 
   
-  Copyright(c) 1999 - 2003 Intel Corporation. All rights reserved.
+  Copyright(c) 1999 - 2004 Intel Corporation. All rights reserved.
   
   This program is free software; you can redistribute it and/or modify it 
   under the terms of the GNU General Public License as published by the Free 
diff -Naurp netdev-2.6/drivers/net/e1000/e1000_hw.h netdev-2.6/drivers/net/e1000.mod/e1000_hw.h
--- netdev-2.6/drivers/net/e1000/e1000_hw.h	2004-02-02 12:11:27.000000000 -0800
+++ netdev-2.6/drivers/net/e1000.mod/e1000_hw.h	2004-02-02 12:12:03.000000000 -0800
@@ -1,7 +1,7 @@
 /*******************************************************************************
 
   
-  Copyright(c) 1999 - 2003 Intel Corporation. All rights reserved.
+  Copyright(c) 1999 - 2004 Intel Corporation. All rights reserved.
   
   This program is free software; you can redistribute it and/or modify it 
   under the terms of the GNU General Public License as published by the Free 
diff -Naurp netdev-2.6/drivers/net/e1000/e1000_main.c netdev-2.6/drivers/net/e1000.mod/e1000_main.c
--- netdev-2.6/drivers/net/e1000/e1000_main.c	2004-02-02 12:11:27.000000000 -0800
+++ netdev-2.6/drivers/net/e1000.mod/e1000_main.c	2004-02-02 12:14:08.000000000 -0800
@@ -1,7 +1,7 @@
 /*******************************************************************************
 
   
-  Copyright(c) 1999 - 2003 Intel Corporation. All rights reserved.
+  Copyright(c) 1999 - 2004 Intel Corporation. All rights reserved.
   
   This program is free software; you can redistribute it and/or modify it 
   under the terms of the GNU General Public License as published by the Free 
@@ -30,7 +30,12 @@
 
 /* Change Log
  *
- * 5.2.27	12/14/03
+ * 5.2.30.1	1/29/03
+ *   o Set VLAN filtering to IEEE 802.1Q after reset so we don't break
+ *     SoL connections that use VLANs.
+ *   o Allow 1000/Full setting for AutoNeg param for Fiber connections
+ *     Jon D Mason [jonmason@us.ibm.com].
+ *   o Race between Tx queue and Tx clean fixed with a spin lock.
  *   o Added netpoll support.
  *   o Fixed endianess bug causing ethtool loopback diags to fail on ppc.
  *   o Use pdev->irq rather than netdev->irq in preparation for MSI support.
@@ -63,8 +68,8 @@
 
 char e1000_driver_name[] = "e1000";
 char e1000_driver_string[] = "Intel(R) PRO/1000 Network Driver";
-char e1000_driver_version[] = "5.2.27-k1";
-char e1000_copyright[] = "Copyright (c) 1999-2003 Intel Corporation.";
+char e1000_driver_version[] = "5.2.30.1-k1";
+char e1000_copyright[] = "Copyright (c) 1999-2004 Intel Corporation.";
 
 /* e1000_pci_tbl - PCI Device ID Table
  *
diff -Naurp netdev-2.6/drivers/net/e1000/e1000_osdep.h netdev-2.6/drivers/net/e1000.mod/e1000_osdep.h
--- netdev-2.6/drivers/net/e1000/e1000_osdep.h	2004-02-02 12:11:27.000000000 -0800
+++ netdev-2.6/drivers/net/e1000.mod/e1000_osdep.h	2004-02-02 12:14:13.000000000 -0800
@@ -1,7 +1,7 @@
 /*******************************************************************************
 
   
-  Copyright(c) 1999 - 2003 Intel Corporation. All rights reserved.
+  Copyright(c) 1999 - 2004 Intel Corporation. All rights reserved.
   
   This program is free software; you can redistribute it and/or modify it 
   under the terms of the GNU General Public License as published by the Free 
diff -Naurp netdev-2.6/drivers/net/e1000/e1000_param.c netdev-2.6/drivers/net/e1000.mod/e1000_param.c
--- netdev-2.6/drivers/net/e1000/e1000_param.c	2004-02-02 12:11:27.000000000 -0800
+++ netdev-2.6/drivers/net/e1000.mod/e1000_param.c	2004-02-02 12:14:52.000000000 -0800
@@ -1,7 +1,7 @@
 /*******************************************************************************
 
   
-  Copyright(c) 1999 - 2003 Intel Corporation. All rights reserved.
+  Copyright(c) 1999 - 2004 Intel Corporation. All rights reserved.
   
   This program is free software; you can redistribute it and/or modify it 
   under the terms of the GNU General Public License as published by the Free 
@@ -63,7 +63,7 @@ MODULE_PARM_DESC(X, S);
 /* Transmit Descriptor Count
  *
  * Valid Range: 80-256 for 82542 and 82543 gigabit ethernet controllers
- * Valid Range: 80-4096 for 82544
+ * Valid Range: 80-4096 for 82544 and newer
  *
  * Default Value: 256
  */
@@ -73,7 +73,7 @@ E1000_PARAM(TxDescriptors, "Number of tr
 /* Receive Descriptor Count
  *
  * Valid Range: 80-256 for 82542 and 82543 gigabit ethernet controllers
- * Valid Range: 80-4096 for 82544
+ * Valid Range: 80-4096 for 82544 and newer
  *
  * Default Value: 256
  */
@@ -289,7 +289,7 @@ static void e1000_check_copper_options(s
  * e1000_check_options - Range Checking for Command Line Parameters
  * @adapter: board private structure
  *
- * This routine checks all command line paramters for valid user
+ * This routine checks all command line parameters for valid user
  * input.  If an invalid value is given, or if no user specified
  * value exists, a default value is used.  The final value is stored
  * in a variable in the adapter structure.
