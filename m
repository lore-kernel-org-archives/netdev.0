From: Ganesh Venkatesan <ganesh.venkatesan@intel.com>
Subject: [Patch 14/16 2.5] ixgb: version number update
Date: Fri, 15 Oct 2004 06:56:13 -0700 (PDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.4.44.0410150642140.31227-100000@isotope.jf.intel.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: "jgarzik@pobox.com" <jgarzik@pobox.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

diff -up net-drivers-2.6/drivers/net/ixgb/ixgb_main.c net-drivers-2.6/drivers/net/ixgb.new/ixgb_main.c
--- net-drivers-2.6/drivers/net/ixgb/ixgb_main.c	2004-10-05 15:50:18.000000000 -0700
+++ net-drivers-2.6/drivers/net/ixgb.new/ixgb_main.c	2004-10-05 17:55:48.000000000 -0700
@@ -30,8 +30,13 @@
 
 char ixgb_driver_name[] = "ixgb";
 char ixgb_driver_string[] = "Intel(R) PRO/10GbE Network Driver";
-char ixgb_driver_version[] = "1.0.66";
-char ixgb_copyright[] = "Copyright (c) 2001-2004 Intel Corporation.";
+#ifndef CONFIG_IXGB_NAPI
+#define DRIVERNAPI
+#else
+#define DRIVERNAPI "-NAPI"
+#endif
+char ixgb_driver_version[] = "1.0.82-k2"DRIVERNAPI;
+char ixgb_copyright[] = "Copyright (c) 2001-2004 Intel Corporation.";
 
 /* ixgb_pci_tbl - PCI Device ID Table
  *
