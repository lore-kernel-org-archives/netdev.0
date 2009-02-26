From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH 10/15] via-rhine: fix non-constant printk warnings
Date: Thu, 26 Feb 2009 12:19:31 -0800
Message-ID: <20090226201950.124821722@vyatta.com>
References: <20090226201921.462146178@vyatta.com>
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from suva.vyatta.com ([76.74.103.44]:38665 "EHLO suva.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755576AbZBZUUU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 26 Feb 2009 15:20:20 -0500
Content-Disposition: inline; filename=via-rhine-warn.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>
--- a/drivers/net/via-rhine.c	2009-02-26 09:54:22.000000000 -0800
+++ b/drivers/net/via-rhine.c	2009-02-26 09:54:48.000000000 -0800
@@ -109,8 +109,9 @@ static const int multicast_filter_limit 
 #include <linux/dmi.h>
 
 /* These identify the driver base version and may not be removed. */
-static char version[] __devinitdata =
-KERN_INFO DRV_NAME ".c:v1.10-LK" DRV_VERSION " " DRV_RELDATE " Written by Donald Becker\n";
+static const char version[] __devinitconst =
+	KERN_INFO DRV_NAME ".c:v1.10-LK" DRV_VERSION " " DRV_RELDATE
+	" Written by Donald Becker\n";
 
 /* This driver was written to use PCI memory space. Some early versions
    of the Rhine may only work correctly with I/O space accesses. */

-- 

