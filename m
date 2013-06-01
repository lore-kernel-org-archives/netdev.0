From: Thomas Meyer <thomas@m3y3r.de>
Subject: [PATCH] netdev: Cocci spatch "ptr_ret.spatch"
Date: Sat, 01 Jun 2013 11:59:11 +0200
Message-ID: <1370080751.29224.37.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from www17.your-server.de ([213.133.104.17]:33049 "EHLO
	www17.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932530Ab3FAJ7Q (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 1 Jun 2013 05:59:16 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Signed-off-by: Thomas Meyer <thomas@m3y3r.de>
---

diff -u -p a/drivers/net/ethernet/smsc/smc9194.c b/drivers/net/ethernet/smsc/smc9194.c
--- a/drivers/net/ethernet/smsc/smc9194.c
+++ b/drivers/net/ethernet/smsc/smc9194.c
@@ -1571,9 +1571,7 @@ int __init init_module(void)
 
 	/* copy the parameters from insmod into the device structure */
 	devSMC9194 = smc_init(-1);
-	if (IS_ERR(devSMC9194))
-		return PTR_ERR(devSMC9194);
-	return 0;
+	return PTR_RET(devSMC9194);
 }
 
 void __exit cleanup_module(void)
