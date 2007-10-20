From: Olof Johansson <olof@lixom.net>
Subject: [PATCH] Fix build break in tsi108.c
Date: Fri, 19 Oct 2007 21:04:20 -0500
Message-ID: <20071020020420.GA20073@lixom.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linuxppc-dev@ozlabs.org, joe@perches.com
To: jgarzik@pobox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from lixom.net ([66.141.50.11]:58383 "EHLO mail.lixom.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1761250AbXJTB5n (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 19 Oct 2007 21:57:43 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Fix build break:

drivers/net/tsi108_eth.c: In function 'tsi108_init_one':
drivers/net/tsi108_eth.c:1633: error: expected ')' before 'dev'
drivers/net/tsi108_eth.c:1633: warning: too few arguments for format
make[2]: *** [drivers/net/tsi108_eth.o] Error 1


Signed-off-by: Olof Johansson <olof@lixom.net>

diff --git a/drivers/net/tsi108_eth.c b/drivers/net/tsi108_eth.c
index df10af7..35d15e8 100644
--- a/drivers/net/tsi108_eth.c
+++ b/drivers/net/tsi108_eth.c
@@ -1629,7 +1629,7 @@ tsi108_init_one(struct platform_device *pdev)
 		goto register_fail;
 	}
 
-	printk(KERN_INFO "%s: Tsi108 Gigabit Ethernet, MAC: %s\n"
+	printk(KERN_INFO "%s: Tsi108 Gigabit Ethernet, MAC: %s\n",
 	       dev->name, print_mac(mac, dev->dev_addr));
 #ifdef DEBUG
 	data->msg_enable = DEBUG;
