From: Matt Domsch <Matt_Domsch@dell.com>
Subject: [PATCH 2.6] e100, e1000, ixgb: add MODULE_VERSION tags
Date: Tue, 2 Nov 2004 13:07:24 -0600
Message-ID: <20041102190724.GA6962@lists.us.dell.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com, linux.nics@intel.com, jgarzik@pobox.com
Content-Disposition: inline
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Patch below adds MODULE_VERSION tags to the e100, e1000, and ixgb
drivers.  Tools like DKMS will make use of this information to
determine if a given driver is older or newer than another given
driver based on this version number.

Signed-off-by: Matt Domsch <Matt_Domsch@dell.com>

-- 
Matt Domsch
Sr. Software Engineer, Lead Engineer
Dell Linux Solutions linux.dell.com & www.dell.com/linux
Linux on Dell mailing lists @ http://lists.us.dell.com

===== drivers/net/e100.c 1.30 vs edited =====
--- 1.30/drivers/net/e100.c	2004-10-25 02:27:41 -05:00
+++ edited/drivers/net/e100.c	2004-11-02 12:49:44 -06:00
@@ -166,6 +166,7 @@
 MODULE_DESCRIPTION(DRV_DESCRIPTION);
 MODULE_AUTHOR(DRV_COPYRIGHT);
 MODULE_LICENSE("GPL");
+MODULE_VERSION(DRV_VERSION);
 
 static int debug = 3;
 module_param(debug, int, 0);
===== drivers/net/e1000/e1000_main.c 1.137 vs edited =====
--- 1.137/drivers/net/e1000/e1000_main.c	2004-10-25 22:41:15 -05:00
+++ edited/drivers/net/e1000/e1000_main.c	2004-11-02 12:55:04 -06:00
@@ -48,7 +48,8 @@
 #else
 #define DRIVERNAPI "-NAPI"
 #endif
-char e1000_driver_version[] = "5.5.4-k2"DRIVERNAPI;
+#define DRV_VERSION "5.5.4-k2"DRIVERNAPI
+char e1000_driver_version[] = DRV_VERSION;
 char e1000_copyright[] = "Copyright (c) 1999-2004 Intel Corporation.";
 
 /* e1000_pci_tbl - PCI Device ID Table
@@ -196,6 +197,7 @@
 MODULE_AUTHOR("Intel Corporation, <linux.nics@intel.com>");
 MODULE_DESCRIPTION("Intel(R) PRO/1000 Network Driver");
 MODULE_LICENSE("GPL");
+MODULE_VERSION(DRV_VERSION);
 
 static int debug = NETIF_MSG_DRV | NETIF_MSG_PROBE;
 module_param(debug, int, 0);
===== drivers/net/ixgb/ixgb_main.c 1.18 vs edited =====
--- 1.18/drivers/net/ixgb/ixgb_main.c	2004-10-25 20:04:30 -05:00
+++ edited/drivers/net/ixgb/ixgb_main.c	2004-11-02 12:56:03 -06:00
@@ -30,7 +30,8 @@
 
 char ixgb_driver_name[] = "ixgb";
 char ixgb_driver_string[] = "Intel(R) PRO/10GbE Network Driver";
-char ixgb_driver_version[] = "1.0.66-k2";
+#define DRV_VERSION "1.0.66-k2"
+char ixgb_driver_version[] = DRV_VERSION;
 char ixgb_copyright[] = "Copyright (c) 2001-2004 Intel Corporation.";
 
 /* ixgb_pci_tbl - PCI Device ID Table
@@ -138,6 +139,7 @@
 MODULE_AUTHOR("Intel Corporation, <linux.nics@intel.com>");
 MODULE_DESCRIPTION("Intel(R) PRO/10GbE Network Driver");
 MODULE_LICENSE("GPL");
+MODULE_VERSION(DRV_VERSION);
 
 /* some defines for controlling descriptor fetches in h/w */
 #define RXDCTL_PTHRESH_DEFAULT 128	/* chip considers prefech below this */
