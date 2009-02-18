From: Roel Kluin <roel.kluin@gmail.com>
Subject: [PATCH] sundance: missing parentheses?
Date: Wed, 18 Feb 2009 10:19:50 +0100
Message-ID: <499BD2B6.1010407@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>
To: Jeff Garzik <jgarzik@pobox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ew0-f21.google.com ([209.85.219.21]:46320 "EHLO
	mail-ew0-f21.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753061AbZBRJTx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Feb 2009 04:19:53 -0500
Received: by ewy14 with SMTP id 14so2611066ewy.13
        for <netdev@vger.kernel.org>; Wed, 18 Feb 2009 01:19:51 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Please review.
--------------------------->8-------------8<------------------------------
Add missing parentheses

Signed-off-by: Roel Kluin <roel.kluin@gmail.com>
---
diff --git a/drivers/net/sundance.c b/drivers/net/sundance.c
index feaf0e0..43695b7 100644
--- a/drivers/net/sundance.c
+++ b/drivers/net/sundance.c
@@ -909,7 +909,7 @@ static void check_duplex(struct net_device *dev)
 			printk(KERN_INFO "%s: Setting %s-duplex based on MII #%d "
 				   "negotiated capability %4.4x.\n", dev->name,
 				   duplex ? "full" : "half", np->phys[0], negotiated);
-		iowrite16(ioread16(ioaddr + MACCtrl0) | duplex ? 0x20 : 0, ioaddr + MACCtrl0);
+		iowrite16(ioread16(ioaddr + MACCtrl0) | (duplex ? 0x20 : 0), ioaddr + MACCtrl0);
 	}
 }
 
