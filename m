From: Stefano Brivio <stefano.brivio@polimi.it>
Subject: [patch 10/10] [RFT] bcm43xx: add PCI ID for bcm4311
Date: Fri, 19 May 2006 00:00:10 +0200
Message-ID: <20060519155801.707656000@polimi.it>
References: <20060519154451.042749000@polimi.it>
Cc: Edgar Hucek <hostmaster@ed-soft.at>,
	Matthew Garrett <mjg59@srcf.ucam.org>,
	Louis E Garcia II <louisg00@bellsouth.net>,
	Stefano Brivio <stefano.brivio@polimi.it>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 213-156-52-114.fastres.net ([213.156.52.114]:55433 "EHLO
	213-156-52-114.fastres.net") by vger.kernel.org with ESMTP
	id S932406AbWESP6G (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 19 May 2006 11:58:06 -0400
To: netdev@vger.kernel.org
Content-Disposition: inline; filename=bcm43xx-pcie_ids.diff
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Add PCI ID for bcm4311 PCI-E device.

Signed-off-by: Stefano Brivio <stefano.brivio@polimi.it>

Index: wireless-dev/drivers/net/wireless/bcm43xx/bcm43xx_main.c
===================================================================
--- wireless-dev.orig/drivers/net/wireless/bcm43xx/bcm43xx_main.c
+++ wireless-dev/drivers/net/wireless/bcm43xx/bcm43xx_main.c
@@ -130,6 +130,8 @@ MODULE_PARM_DESC(fwpostfix, "Postfix for
 	{ PCI_VENDOR_ID_BROADCOM, 0x4301, PCI_ANY_ID, PCI_ANY_ID, 0, 0, 0 },
 		/* Broadcom 4307 802.11b */
 	{ PCI_VENDOR_ID_BROADCOM, 0x4307, PCI_ANY_ID, PCI_ANY_ID, 0, 0, 0 },
+	/* Broadcom 4311 802.11(a)/b/g */
+	{ PCI_VENDOR_ID_BROADCOM, 0x4311, PCI_ANY_ID, PCI_ANY_ID, 0, 0, 0 },
 		/* Broadcom 4318 802.11b/g */
 	{ PCI_VENDOR_ID_BROADCOM, 0x4318, PCI_ANY_ID, PCI_ANY_ID, 0, 0, 0 },
 	/* Broadcom 4306 802.11b/g */

--
Ciao
Stefano
