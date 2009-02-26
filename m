From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH 14/15] forcedeth: fix non-constant printk warnings
Date: Thu, 26 Feb 2009 12:19:35 -0800
Message-ID: <20090226201950.586780549@vyatta.com>
References: <20090226201921.462146178@vyatta.com>
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from suva.vyatta.com ([76.74.103.44]:38669 "EHLO suva.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755668AbZBZUUV (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 26 Feb 2009 15:20:21 -0500
Content-Disposition: inline; filename=forcedeth-warn.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>
--- a/drivers/net/forcedeth.c	2009-02-26 09:57:47.000000000 -0800
+++ b/drivers/net/forcedeth.c	2009-02-26 09:59:00.000000000 -0800
@@ -940,7 +940,7 @@ static int reg_delay(struct net_device *
 		delaymax -= delay;
 		if (delaymax < 0) {
 			if (msg)
-				printk(msg);
+				printk("%s", msg);
 			return 1;
 		}
 	} while ((readl(base + offset) & mask) != target);

-- 

