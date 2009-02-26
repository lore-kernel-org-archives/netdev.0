From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH 09/15] fealnx: fix non-constant printk warnings
Date: Thu, 26 Feb 2009 12:19:30 -0800
Message-ID: <20090226201950.007320605@vyatta.com>
References: <20090226201921.462146178@vyatta.com>
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from suva.vyatta.com ([76.74.103.44]:38664 "EHLO suva.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755518AbZBZUUU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 26 Feb 2009 15:20:20 -0500
Content-Disposition: inline; filename=fealnx-warn.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>
--- a/drivers/net/fealnx.c	2009-02-26 09:52:30.000000000 -0800
+++ b/drivers/net/fealnx.c	2009-02-26 09:53:42.000000000 -0800
@@ -93,8 +93,8 @@ static int full_duplex[MAX_UNITS] = { -1
 #include <asm/byteorder.h>
 
 /* These identify the driver base version and may not be removed. */
-static char version[] =
-KERN_INFO DRV_NAME ".c:v" DRV_VERSION " " DRV_RELDATE "\n";
+static const char version[] __devinitconst =
+	KERN_INFO DRV_NAME ".c:v" DRV_VERSION " " DRV_RELDATE "\n";
 
 
 /* This driver was written to use PCI memory space, however some x86 systems

-- 

