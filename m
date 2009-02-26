From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH 04/15] ne2k-pci: fix non-constant printk warnings
Date: Thu, 26 Feb 2009 12:19:25 -0800
Message-ID: <20090226201949.420507710@vyatta.com>
References: <20090226201921.462146178@vyatta.com>
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from suva.vyatta.com ([76.74.103.44]:38659 "EHLO suva.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755232AbZBZUUU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 26 Feb 2009 15:20:20 -0500
Content-Disposition: inline; filename=ne2k-warn.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

--- a/drivers/net/ne2k-pci.c	2009-02-26 09:46:41.000000000 -0800
+++ b/drivers/net/ne2k-pci.c	2009-02-26 09:47:11.000000000 -0800
@@ -62,8 +62,9 @@ static int options[MAX_UNITS];
 #include "8390.h"
 
 /* These identify the driver base version and may not be removed. */
-static char version[] __devinitdata =
-KERN_INFO DRV_NAME ".c:v" DRV_VERSION " " DRV_RELDATE " D. Becker/P. Gortmaker\n";
+static const char version[] __devinitconst =
+	KERN_INFO DRV_NAME ".c:v" DRV_VERSION " " DRV_RELDATE
+	" D. Becker/P. Gortmaker\n";
 
 #if defined(__powerpc__)
 #define inl_le(addr)  le32_to_cpu(inl(addr))

-- 

