From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH 11/15] starfire: fix non-constant printk warnings
Date: Thu, 26 Feb 2009 12:19:32 -0800
Message-ID: <20090226201950.239806927@vyatta.com>
References: <20090226201921.462146178@vyatta.com>
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from suva.vyatta.com ([76.74.103.44]:38666 "EHLO suva.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755605AbZBZUUU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 26 Feb 2009 15:20:20 -0500
Content-Disposition: inline; filename=starfire-warn.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>
--- a/drivers/net/starfire.c	2009-02-26 09:55:51.000000000 -0800
+++ b/drivers/net/starfire.c	2009-02-26 09:56:33.000000000 -0800
@@ -178,7 +178,7 @@ static int full_duplex[MAX_UNITS] = {0, 
 #define FIRMWARE_TX	"adaptec/starfire_tx.bin"
 
 /* These identify the driver base version and may not be removed. */
-static char version[] =
+static const char version[] __devinitconst =
 KERN_INFO "starfire.c:v1.03 7/26/2000  Written by Donald Becker <becker@scyld.com>\n"
 KERN_INFO " (unofficial 2.2/2.4 kernel port, version " DRV_VERSION ", " DRV_RELDATE ")\n";
 

-- 

