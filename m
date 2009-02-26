From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH 08/15] natsemi: fix non-constant printk warnings
Date: Thu, 26 Feb 2009 12:19:29 -0800
Message-ID: <20090226201949.891519044@vyatta.com>
References: <20090226201921.462146178@vyatta.com>
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from suva.vyatta.com ([76.74.103.44]:38663 "EHLO suva.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755477AbZBZUUU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 26 Feb 2009 15:20:20 -0500
Content-Disposition: inline; filename=natsemi-warn.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>
--- a/drivers/net/natsemi.c	2009-02-26 09:51:52.000000000 -0800
+++ b/drivers/net/natsemi.c	2009-02-26 09:52:05.000000000 -0800
@@ -127,7 +127,7 @@ static int full_duplex[MAX_UNITS];
 #define NATSEMI_RX_LIMIT	2046	/* maximum supported by hardware */
 
 /* These identify the driver base version and may not be removed. */
-static char version[] __devinitdata =
+static const char version[] __devinitconst =
   KERN_INFO DRV_NAME " dp8381x driver, version "
       DRV_VERSION ", " DRV_RELDATE "\n"
   KERN_INFO "  originally by Donald Becker <becker@scyld.com>\n"

-- 

