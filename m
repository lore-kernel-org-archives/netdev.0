From: ganesh.venkatesan@intel.com
Subject: [PATCH 6/6 2.5] e100 - driver version update
Date: Thu, 29 Jul 2004 08:27:16 -0700 (PDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.4.44.0407290659060.21929-100000@westville2.jf.intel.com>
Reply-To: ganesh.venkatesan@intel.com
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@oss.sgi.com, <ganesh.venkatesan@intel.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: jgarzik@pobox.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

--- linux-2.5/drivers/net/e100.c	2004-07-29 00:29:00.291434840 -0700
+++ linux-2.5/drivers/net/e100.c.mod	2004-07-29 00:29:27.438307888 -0700
@@ -158,7 +158,12 @@
 
 
 #define DRV_NAME		"e100"
-#define DRV_VERSION		"3.0.18"
+#ifndef CONFIG_E100_NAPI
+#define DRV_EXT
+#else
+#define DRV_EXT		"-NAPI"
+#endif
+#define DRV_VERSION		"3.0.27-k2"DRV_EXT
 #define DRV_DESCRIPTION		"Intel(R) PRO/100 Network Driver"
 #define DRV_COPYRIGHT		"Copyright(c) 1999-2004 Intel Corporation"
 #define PFX			DRV_NAME ": "
