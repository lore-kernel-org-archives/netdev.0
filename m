From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH 01/15] tulip: get rid of warning for non-const string literal
Date: Thu, 26 Feb 2009 12:19:22 -0800
Message-ID: <20090226201949.162730782@vyatta.com>
References: <20090226201921.462146178@vyatta.com>
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from suva.vyatta.com ([76.74.103.44]:38655 "EHLO suva.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755234AbZBZUUU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 26 Feb 2009 15:20:20 -0500
Content-Disposition: inline; filename=dmfe-string.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

--- a/drivers/net/tulip/dmfe.c	2009-02-26 09:35:40.000000000 -0800
+++ b/drivers/net/tulip/dmfe.c	2009-02-26 09:36:21.000000000 -0800
@@ -288,7 +288,7 @@ enum dmfe_CR6_bits {
 
 /* Global variable declaration ----------------------------- */
 static int __devinitdata printed_version;
-static char version[] __devinitdata =
+static const char version[] __devinitconst =
 	KERN_INFO DRV_NAME ": Davicom DM9xxx net driver, version "
 	DRV_VERSION " (" DRV_RELDATE ")\n";
 
--- a/drivers/net/tulip/winbond-840.c	2009-02-26 09:37:40.000000000 -0800
+++ b/drivers/net/tulip/winbond-840.c	2009-02-26 09:39:38.000000000 -0800
@@ -139,9 +139,10 @@ static int full_duplex[MAX_UNITS] = {-1,
 #define PKT_BUF_SZ		1536	/* Size of each temporary Rx buffer.*/
 
 /* These identify the driver base version and may not be removed. */
-static const char version[] __initdata =
-KERN_INFO DRV_NAME ".c:v" DRV_VERSION " (2.4 port) " DRV_RELDATE "  Donald Becker <becker@scyld.com>\n"
-KERN_INFO "  http://www.scyld.com/network/drivers.html\n";
+static const char version[] __initconst =
+	KERN_INFO DRV_NAME ".c:v" DRV_VERSION " (2.4 port) "
+	DRV_RELDATE "  Donald Becker <becker@scyld.com>\n"
+	KERN_INFO "  http://www.scyld.com/network/drivers.html\n";
 
 MODULE_AUTHOR("Donald Becker <becker@scyld.com>");
 MODULE_DESCRIPTION("Winbond W89c840 Ethernet driver");
--- a/drivers/net/tulip/de4x5.c	2009-02-26 09:40:54.000000000 -0800
+++ b/drivers/net/tulip/de4x5.c	2009-02-26 09:41:38.000000000 -0800
@@ -479,7 +479,7 @@
 
 #include "de4x5.h"
 
-static const char version[] __devinitdata =
+static const char version[] __devinitconst =
 	KERN_INFO "de4x5.c:V0.546 2001/02/22 davies@maniac.ultranet.com\n";
 
 #define c_char const char
--- a/drivers/net/tulip/uli526x.c	2009-02-26 09:41:52.000000000 -0800
+++ b/drivers/net/tulip/uli526x.c	2009-02-26 09:42:14.000000000 -0800
@@ -200,7 +200,7 @@ enum uli526x_CR6_bits {
 
 /* Global variable declaration ----------------------------- */
 static int __devinitdata printed_version;
-static char version[] __devinitdata =
+static const char version[] __devinitconst =
 	KERN_INFO DRV_NAME ": ULi M5261/M5263 net driver, version "
 	DRV_VERSION " (" DRV_RELDATE ")\n";
 

-- 

