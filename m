From: Lennert Buytenhek <buytenh@wantstofly.org>
Subject: [PATCH 09/10] mv643xx_eth: print driver version on init
Date: Wed, 16 Jul 2008 12:33:01 +0200
Message-ID: <20080716103301.GJ8545@xi.wantstofly.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from xi.wantstofly.org ([83.160.184.112]:44742 "EHLO
	xi.wantstofly.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753900AbYGPKdE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Jul 2008 06:33:04 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Print the mv643xx_eth driver version on init to help debugging.

Signed-off-by: Lennert Buytenhek <buytenh@marvell.com>

diff --git a/drivers/net/mv643xx_eth.c b/drivers/net/mv643xx_eth.c
index 5bed6b3..006ad45 100644
--- a/drivers/net/mv643xx_eth.c
+++ b/drivers/net/mv643xx_eth.c
@@ -2249,7 +2249,8 @@ static int mv643xx_eth_shared_probe(struct platform_device *pdev)
 	int ret;
 
 	if (!mv643xx_eth_version_printed++)
-		printk(KERN_NOTICE "MV-643xx 10/100/1000 Ethernet Driver\n");
+		printk(KERN_NOTICE "MV-643xx 10/100/1000 ethernet "
+			"driver version %s\n", mv643xx_eth_driver_version);
 
 	ret = -EINVAL;
 	res = platform_get_resource(pdev, IORESOURCE_MEM, 0);
-- 
1.5.3.4
