From: "Alex Bounine" <alex.bou9@gmail.com>
Subject: [PATCH 1/5 v3] Tsi108_eth: add missing linking to driver data
Date: Mon, 11 Feb 2008 14:33:40 -0500
Message-ID: <d5f62df20802111133x4c1669efybb0895c3f2210f6e@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: linuxppc-dev@ozlabs.org, tie-fei.zang@freescale.com,
	jwboyer@linux.vnet.ibm.com
To: jgarzik@pobox.com, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from wx-out-0506.google.com ([66.249.82.235]:30969 "EHLO
	wx-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756872AbYBKTdp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Feb 2008 14:33:45 -0500
Received: by wx-out-0506.google.com with SMTP id h31so4881483wxd.4
        for <netdev@vger.kernel.org>; Mon, 11 Feb 2008 11:33:42 -0800 (PST)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Bug fix for tsi108_eth network driver.
This patch adds missing linking to driver data.

Signed-off-by: Alexandre Bounine <alexandreb@tundra.com>
---

diff -pNur linux-2.6.24/drivers/net/tsi108_eth.c
linux-2.6.24-fix/drivers/net/tsi108_eth.c
--- linux-2.6.24/drivers/net/tsi108_eth.c	2008-01-24 17:58:37.000000000 -0500
+++ linux-2.6.24-fix/drivers/net/tsi108_eth.c	2008-02-06
14:30:04.000000000 -0500
@@ -1629,6 +1629,7 @@ tsi108_init_one(struct platform_device *
 		goto register_fail;
 	}

+	platform_set_drvdata(pdev, dev);
 	printk(KERN_INFO "%s: Tsi108 Gigabit Ethernet, MAC: %s\n",
 	       dev->name, print_mac(mac, dev->dev_addr));
 #ifdef DEBUG
