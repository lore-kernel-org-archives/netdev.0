From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH 05/15] sis900: fix non-constant printk warnings
Date: Thu, 26 Feb 2009 12:19:26 -0800
Message-ID: <20090226201949.536948152@vyatta.com>
References: <20090226201921.462146178@vyatta.com>
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from suva.vyatta.com ([76.74.103.44]:38661 "EHLO suva.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755321AbZBZUUU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 26 Feb 2009 15:20:20 -0500
Content-Disposition: inline; filename=sis190-warn.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>
--- a/drivers/net/sis900.c	2009-02-26 12:06:05.000000000 -0800
+++ b/drivers/net/sis900.c	2009-02-26 12:13:03.000000000 -0800
@@ -80,8 +80,8 @@
 #define SIS900_MODULE_NAME "sis900"
 #define SIS900_DRV_VERSION "v1.08.10 Apr. 2 2006"
 
-static char version[] __devinitdata =
-KERN_INFO "sis900.c: " SIS900_DRV_VERSION "\n";
+static const char version[] __devinitconst =
+	KERN_INFO "sis900.c: " SIS900_DRV_VERSION "\n";
 
 static int max_interrupt_work = 40;
 static int multicast_filter_limit = 128;

-- 

