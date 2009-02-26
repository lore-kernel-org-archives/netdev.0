From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH 12/15] sundance: fix non-constant printk warnings
Date: Thu, 26 Feb 2009 12:19:33 -0800
Message-ID: <20090226201950.354602297@vyatta.com>
References: <20090226201921.462146178@vyatta.com>
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from suva.vyatta.com ([76.74.103.44]:38667 "EHLO suva.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755618AbZBZUUV (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 26 Feb 2009 15:20:21 -0500
Content-Disposition: inline; filename=sundance-warn.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>
--- a/drivers/net/sundance.c	2009-02-26 09:56:36.000000000 -0800
+++ b/drivers/net/sundance.c	2009-02-26 09:57:08.000000000 -0800
@@ -109,8 +109,9 @@ static char *media[MAX_UNITS];
 #endif
 
 /* These identify the driver base version and may not be removed. */
-static char version[] =
-KERN_INFO DRV_NAME ".c:v" DRV_VERSION " " DRV_RELDATE "  Written by Donald Becker\n";
+static const char version[] __devinitconst =
+	KERN_INFO DRV_NAME ".c:v" DRV_VERSION " " DRV_RELDATE
+	" Written by Donald Becker\n";
 
 MODULE_AUTHOR("Donald Becker <becker@scyld.com>");
 MODULE_DESCRIPTION("Sundance Alta Ethernet driver");

-- 

