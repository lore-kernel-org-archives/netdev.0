From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH 13/15] hamachi: fix non-constant printk warnings
Date: Thu, 26 Feb 2009 12:19:34 -0800
Message-ID: <20090226201950.470563340@vyatta.com>
References: <20090226201921.462146178@vyatta.com>
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from suva.vyatta.com ([76.74.103.44]:38668 "EHLO suva.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755637AbZBZUUV (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 26 Feb 2009 15:20:21 -0500
Content-Disposition: inline; filename=hamachi-warn.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>
--- a/drivers/net/hamachi.c	2009-02-26 09:57:31.000000000 -0800
+++ b/drivers/net/hamachi.c	2009-02-26 09:57:46.000000000 -0800
@@ -171,7 +171,7 @@ static int tx_params[MAX_UNITS] = {-1, -
 #include <asm/unaligned.h>
 #include <asm/cache.h>
 
-static char version[] __devinitdata =
+static const char version[] __devinitconst =
 KERN_INFO DRV_NAME ".c:v" DRV_VERSION " " DRV_RELDATE "  Written by Donald Becker\n"
 KERN_INFO "   Some modifications by Eric kasten <kasten@nscl.msu.edu>\n"
 KERN_INFO "   Further modifications by Keith Underwood <keithu@parl.clemson.edu>\n";

-- 

