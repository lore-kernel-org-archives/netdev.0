From: Ganesh Venkatesan <ganesh.venkatesan@intel.com>
Subject: [PATCH 2.6] e100: Documentation/networking/e100.txt update
Date: Thu, 6 Jan 2005 17:04:07 -0800 (PST)
Message-ID: <Pine.LNX.4.44.0501061413010.7330-100000@isotope.jf.intel.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: "jgarzik@pobox.com" <jgarzik@pobox.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Signed-off-by: Ganesh Venkatesan <ganesh.venkatesan@intel.com>

diff -Nuar -u net-drivers-2.6/Documentation/networking/e100.txt net-drivers-2.6.new/Documentation/networking/e100.txt
--- net-drivers-2.6/Documentation/networking/e100.txt	2004-10-26 04:14:03.000000000 -0700
+++ net-drivers-2.6.new/Documentation/networking/e100.txt	2005-01-06 11:01:18.000000000 -0800
@@ -1,7 +1,7 @@
 Linux* Base Driver for the Intel(R) PRO/100 Family of Adapters
 ==============================================================
 
-September 13, 2004
+November 17, 2004
 
 
 Contents
@@ -18,9 +18,7 @@
 ===============
 
 This file describes the Linux* Base Driver for the Intel(R) PRO/100 Family of
-Adapters, version 3.2.x.  This driver includes support for Itanium(TM)2 and
-EM64T systems.
-
+Adapters, version 3.3.x.  This driver supports 2.4.x and 2.6.x kernels. 
 
 Identifying Your Adapter
 ========================
@@ -119,12 +117,6 @@
   The latest release of ethtool can be found at:
   http://sf.net/projects/gkernel.  
 
-  After ethtool is installed, ethtool-copy.h must be copied and renamed to
-  ethtool.h in your kernel source tree at <linux_kernel_src>/include/linux.  
-  Backup the original ethtool.h as needed before copying.  The driver then 
-  must be recompiled in order to take advantage of the latest ethtool 
-  features.
-
   NOTE: This driver uses mii support from the kernel. As a result, when 
   there is no link, ethtool will report speed/duplex to be 10/half.
 
