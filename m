From: Ganesh Venkatesan <ganesh.venkatesan@intel.com>
Subject: [Patch 3/3 2.5] ixgb: Configuration and user guide update
Date: Fri, 15 Oct 2004 06:50:40 -0700 (PDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.4.44.0410150521010.31227-100000@isotope.jf.intel.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: "jgarzik@pobox.com" <jgarzik@pobox.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

diff -Nuarp old/linux-2.5/Documentation/networking/ixgb.txt new/linux-2.5/Documentation/networking/ixgb.txt
--- old/linux-2.5/Documentation/networking/ixgb.txt	2004-10-07 15:50:50.000000000 -0700
+++ new/linux-2.5/Documentation/networking/ixgb.txt	2004-10-07 15:51:47.000000000 -0700
@@ -1,14 +1,14 @@
 Linux* Base Driver for the Intel(R) PRO/10GbE Family of Adapters
 ================================================================
 
-January 06, 2003
+September 13, 2004
 
 
 Contents
 ========
 
 - In This Release
-- Supported Adapters
+- Identifying Your Adapter
 - Command Line Parameters
 - Improving Performance
 - Support
@@ -18,36 +18,23 @@ In This Release
 ===============
 
 This file describes the Linux* Base Driver for the Intel(R) PRO/10GbE Family 
-of Adapters, version 1.0.x. This driver is intended for 2.4.x kernels; it is 
-known to build properly on 2.4.x kernels through 2.4.18. Intel focused 
-testing on Intel architectures running kernels 2.4.18. This driver includes 
-support for Itanium(TM)-based systems.
+of Adapters, version 1.0.x.  This driver includes support for Itanium(TM)2 and
+EM64T systems.
 
 For questions related to hardware requirements, refer to the documentation 
 supplied with your Intel PRO/10GbE adapter. All hardware requirements listed 
 apply to use with Linux.
 
-
-Supported Adapters
-==================
-
-The following Intel network adapters are compatible with the drivers in this 
-release:
-
-   Controller  Adapter Name                           Board IDs
-   ----------  ------------                           ---------
-
-   82597EX     Intel(R) PRO/10GbE LR Server Adapter   A82505-xxx
-
+Identifying Your Adapter
+========================
 
 To verify your Intel adapter is supported, find the board ID number on the 
 adapter. Look for a label that has a barcode and a number in the format  
-A12345-001. Match this to the list of numbers above.
+A12345-001. 
 
-For more information on how to identify your adapter, go to the Adapter & 
-Driver ID Guide at:
+Use the above information and the Adapter & Driver ID Guide at:
 
-    http://support.intel.com/support/network/adapter/pro100/21397.htm
+  http://support.intel.com/support/network/adapter/pro100/21397.htm
 
 For the latest Intel network drivers for Linux, go to:
 
@@ -72,8 +59,9 @@ loads the ixgb driver with 80 TX resourc
 resources for the second adapter.
 
 The default value for each parameter is generally the recommended setting,
-unless otherwise noted.
-
+unless otherwise noted. Also, if the driver is statically built into the
+kernel, the driver is loaded with the default values for all the parameters.
+Ethtool can be used to change some of the parameters at runtime.
 
 FlowControl
 Valid Range: 0-3 (0=none, 1=Rx only, 2=Tx only, 3=Rx&Tx)
@@ -125,7 +113,6 @@ Default Value: 1
     offload for transmitted packets (both UDP and TCP) to the adapter 
     hardware.
 
-
 Improving Performance
 =====================
 
diff -Nuarp old/linux-2.5/drivers/net/Kconfig new/linux-2.5/drivers/net/Kconfig
--- old/linux-2.5/drivers/net/Kconfig	2004-10-07 15:52:11.000000000 -0700
+++ new/linux-2.5/drivers/net/Kconfig	2004-10-07 15:52:27.000000000 -0700
@@ -2132,14 +2132,8 @@ config IXGB
 	depends on PCI
 	---help---
 	  This driver supports Intel(R) PRO/10GbE family of
-	  adapters, which includes:
-
-	  Controller  Adapter Name                           Board IDs
-	  ----------  ------------                           ---------
-	  82597EX     Intel(R) PRO/10GbE LR Server Adapter   A82505-xxx
-
-	  For more information on how to identify your adapter, go to the
-	  Adapter & Driver ID Guide at:
+	  adapters.  For more information on how to identify your adapter, go
+	  to the Adapter & Driver ID Guide at:
 
 	  <http://support.intel.com/support/network/adapter/pro100/21397.htm>
 
