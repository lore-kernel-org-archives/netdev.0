From: Ganesh Venkatesan <ganesh.venkatesan@intel.com>
Subject: [PATCH 2.6] ixgb: Documentation/networking/ixgb.txt
Date: Thu, 6 Jan 2005 17:03:57 -0800 (PST)
Message-ID: <Pine.LNX.4.44.0501061422550.7330-100000@isotope.jf.intel.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: "jgarzik@pobox.com" <jgarzik@pobox.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Signed-off-by: Ganesh Venkatesan <ganesh.venkatesan@intel.com>

diff -Nuar -u net-drivers-2.6/Documentation/networking/ixgb.txt net-drivers-2.6.new/Documentation/networking/ixgb.txt
--- net-drivers-2.6/Documentation/networking/ixgb.txt	2004-10-26 04:14:03.000000000 -0700
+++ net-drivers-2.6.new/Documentation/networking/ixgb.txt	2005-01-06 11:01:30.000000000 -0800
@@ -1,7 +1,7 @@
 Linux* Base Driver for the Intel(R) PRO/10GbE Family of Adapters
 ================================================================
 
-September 13, 2004
+November 17, 2004
 
 
 Contents
@@ -18,8 +18,7 @@
 ===============
 
 This file describes the Linux* Base Driver for the Intel(R) PRO/10GbE Family 
-of Adapters, version 1.0.x.  This driver includes support for Itanium(TM)2 and
-EM64T systems.
+of Adapters, version 1.0.x.  
 
 For questions related to hardware requirements, refer to the documentation 
 supplied with your Intel PRO/10GbE adapter. All hardware requirements listed 
@@ -71,8 +70,8 @@
     Ethernet PAUSE frames.
 
 RxDescriptors
-Valid Range: 64-4096
-Default Value: 1024
+Valid Range: 64-512
+Default Value: 512
     This value is the number of receive descriptors allocated by the driver. 
     Increasing this value allows the driver to buffer more incoming packets. 
     Each descriptor is 16 bytes.  A receive buffer is also allocated for 
