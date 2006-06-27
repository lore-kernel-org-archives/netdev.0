From: Michael Buesch <mb@bu3sch.de>
Subject: [PATCH] bcm43xx: lower mac_suspend udelay
Date: Tue, 27 Jun 2006 17:56:44 +0200
Message-ID: <200606271756.44457.mb@bu3sch.de>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Jeff Garzik <jeff@garzik.org>, bcm43xx-dev@lists.berlios.de,
	Larry Finger <Larry.Finger@lwfinger.net>,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from static-ip-62-75-166-246.inaddr.intergenia.de ([62.75.166.246]:31876
	"EHLO bu3sch.de") by vger.kernel.org with ESMTP id S1161128AbWF0P6O
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 27 Jun 2006 11:58:14 -0400
To: linville@tuxdriver.com
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Microoptimization:
This reduces the udelay in bcm43xx_mac_suspend.

Signed-off-by: Michael Buesch <mb@bu3sch.de>

Index: wireless-2.6/drivers/net/wireless/bcm43xx/bcm43xx_main.c
===================================================================
--- wireless-2.6.orig/drivers/net/wireless/bcm43xx/bcm43xx_main.c	2006-06-27 17:47:24.000000000 +0200
+++ wireless-2.6/drivers/net/wireless/bcm43xx/bcm43xx_main.c	2006-06-27 17:53:29.000000000 +0200
@@ -2328,7 +2328,7 @@
 			tmp = bcm43xx_read32(bcm, BCM43xx_MMIO_GEN_IRQ_REASON);
 			if (tmp & BCM43xx_IRQ_READY)
 				goto out;
-			udelay(10);
+			udelay(1);
 		}
 		printkl(KERN_ERR PFX "MAC suspend failed\n");
 	}

-- 
Greetings Michael.
