From: akpm@osdl.org
Subject: [patch 01/17] clean up initcall warning for netconsole
Date: Thu, 01 Jun 2006 20:32:20 -0700
Message-ID: <200606020328.k523S1eJ028805@shell0.pdx.osdl.net>
Cc: netdev@vger.kernel.org, akpm@osdl.org, mpm@selenic.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:55220 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S1751191AbWFBD2I (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 1 Jun 2006 23:28:08 -0400
To: davem@davemloft.net
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


From: Matt Mackall <mpm@selenic.com>

netconsole is being wrong here.  If it wasn't enabled there's no error.


Signed-off-by: Andrew Morton <akpm@osdl.org>
---

 drivers/net/netconsole.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff -puN drivers/net/netconsole.c~clean-up-initcall-warning-for-netconsole drivers/net/netconsole.c
--- devel/drivers/net/netconsole.c~clean-up-initcall-warning-for-netconsole	2006-06-01 20:31:49.000000000 -0700
+++ devel-akpm/drivers/net/netconsole.c	2006-06-01 20:31:49.000000000 -0700
@@ -107,7 +107,7 @@ static int init_netconsole(void)
 
 	if(!configured) {
 		printk("netconsole: not configured, aborting\n");
-		return -EINVAL;
+		return 0;
 	}
 
 	if(netpoll_setup(&np))
_
