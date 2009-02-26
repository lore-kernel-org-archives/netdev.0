From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH 02/15] lapb: get rid of non-const printk warning
Date: Thu, 26 Feb 2009 12:19:23 -0800
Message-ID: <20090226201949.230418756@vyatta.com>
References: <20090226201921.462146178@vyatta.com>
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from suva.vyatta.com ([76.74.103.44]:38657 "EHLO suva.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755244AbZBZUUU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 26 Feb 2009 15:20:20 -0500
Content-Disposition: inline; filename=lapb-warn.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

--- a/drivers/net/wan/lapbether.c	2009-02-26 12:06:07.000000000 -0800
+++ b/drivers/net/wan/lapbether.c	2009-02-26 12:12:26.000000000 -0800
@@ -430,7 +430,7 @@ static struct notifier_block lapbeth_dev
 	.notifier_call = lapbeth_device_event,
 };
 
-static const char banner[] __initdata =
+static const char banner[] __initconst =
 	KERN_INFO "LAPB Ethernet driver version 0.02\n";
 
 static int __init lapbeth_init_driver(void)

-- 

