From: "John W. Linville" <linville@tuxdriver.com>
Subject: [patch netdev-2.6] e1000: add MODULE_VERSION
Date: Wed, 30 Mar 2005 13:44:03 -0500
Message-ID: <20050330184403.GD10049@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com, jgarzik@pobox.com, ayyappan.veeraiyan@intel.com,
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

 drivers/net/e1000/e1000_main.c |    4 +++-
 1 files changed, 3 insertions(+), 1 deletion(-)

--- netdev-2.6/drivers/net/e1000/e1000_main.c.orig	2005-03-30 13:30:02.355409590 -0500
+++ netdev-2.6/drivers/net/e1000/e1000_main.c	2005-03-30 13:31:13.174846755 -0500
@@ -65,7 +65,8 @@ char e1000_driver_string[] = "Intel(R) P
 #else
 #define DRIVERNAPI "-NAPI"
 #endif
-char e1000_driver_version[] = "5.7.6-k2"DRIVERNAPI;
+#define DRV_VERSION "5.7.6-k2"DRIVERNAPI
+char e1000_driver_version[] = DRV_VERSION;
 char e1000_copyright[] = "Copyright (c) 1999-2004 Intel Corporation.";
 
 /* e1000_pci_tbl - PCI Device ID Table
@@ -210,6 +211,7 @@ static struct pci_driver e1000_driver = 
 MODULE_AUTHOR("Intel Corporation, <linux.nics@intel.com>");
 MODULE_DESCRIPTION("Intel(R) PRO/1000 Network Driver");
 MODULE_LICENSE("GPL");
+MODULE_VERSION(DRV_VERSION);
 
 static int debug = NETIF_MSG_DRV | NETIF_MSG_PROBE;
 module_param(debug, int, 0);
-- 
John W. Linville
linville@tuxdriver.com
