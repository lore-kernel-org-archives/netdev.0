From: "John W. Linville" <linville@tuxdriver.com>
Subject: [patch netdev-2.6] ixgb: Add MODULE_VERSION
Date: Wed, 30 Mar 2005 13:43:23 -0500
Message-ID: <20050330184321.GC10049@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com, jgarzik@pobox.com, cramerj@intel.com,
        john.ronciak@intel.com, ganesh.venkatesan@intel.com
Return-path: <netdev-bounce@oss.sgi.com>
To: linux-kernel@vger.kernel.org
Content-Disposition: inline
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Add MODULE_VERSION entry.

Signed-off-by: John W. Linville <linville@tuxdriver.com>
---
I posted one like this before, but it seems to have been lost or
overwritten...

 drivers/net/ixgb/ixgb_main.c |    4 +++-
 1 files changed, 3 insertions(+), 1 deletion(-)

--- netdev-2.6/drivers/net/ixgb/ixgb_main.c.orig	2005-03-30 13:34:37.803202027 -0500
+++ netdev-2.6/drivers/net/ixgb/ixgb_main.c	2005-03-30 13:34:12.038683827 -0500
@@ -47,7 +47,8 @@ char ixgb_driver_string[] = "Intel(R) PR
 #else
 #define DRIVERNAPI "-NAPI"
 #endif
-char ixgb_driver_version[] = "1.0.90-k2"DRIVERNAPI;
+#define DRV_VERSION "1.0.90-k2"DRIVERNAPI
+char ixgb_driver_version[] = DRV_VERSION;
 char ixgb_copyright[] = "Copyright (c) 1999-2005 Intel Corporation.";
 
 /* ixgb_pci_tbl - PCI Device ID Table
@@ -152,6 +153,7 @@ static struct pci_driver ixgb_driver = {
 MODULE_AUTHOR("Intel Corporation, <linux.nics@intel.com>");
 MODULE_DESCRIPTION("Intel(R) PRO/10GbE Network Driver");
 MODULE_LICENSE("GPL");
+MODULE_VERSION(DRV_VERSION);
 
 /* some defines for controlling descriptor fetches in h/w */
 #define RXDCTL_PTHRESH_DEFAULT 128	/* chip considers prefech below this */
-- 
John W. Linville
linville@tuxdriver.com
