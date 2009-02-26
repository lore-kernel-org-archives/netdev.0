From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH 06/15] yellowfin: fix non-constant printk warnings
Date: Thu, 26 Feb 2009 12:19:27 -0800
Message-ID: <20090226201949.654794750@vyatta.com>
References: <20090226201921.462146178@vyatta.com>
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from suva.vyatta.com ([76.74.103.44]:38662 "EHLO suva.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755354AbZBZUUU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 26 Feb 2009 15:20:20 -0500
Content-Disposition: inline; filename=yellowfin-warn.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>
--- a/drivers/net/yellowfin.c	2009-02-26 09:49:41.000000000 -0800
+++ b/drivers/net/yellowfin.c	2009-02-26 09:50:24.000000000 -0800
@@ -107,9 +107,9 @@ static int gx_fix;
 #include <asm/io.h>
 
 /* These identify the driver base version and may not be removed. */
-static char version[] __devinitdata =
-KERN_INFO DRV_NAME ".c:v1.05  1/09/2001  Written by Donald Becker <becker@scyld.com>\n"
-KERN_INFO "  (unofficial 2.4.x port, " DRV_VERSION ", " DRV_RELDATE ")\n";
+static const char version[] __devinitconst =
+  KERN_INFO DRV_NAME ".c:v1.05  1/09/2001  Written by Donald Becker <becker@scyld.com>\n"
+  KERN_INFO "  (unofficial 2.4.x port, " DRV_VERSION ", " DRV_RELDATE ")\n";
 
 MODULE_AUTHOR("Donald Becker <becker@scyld.com>");
 MODULE_DESCRIPTION("Packet Engines Yellowfin G-NIC Gigabit Ethernet driver");

-- 

