From: Stefano Brivio <stefano.brivio@polimi.it>
Subject: [PATCH 2/2] bcm43xx: add PCI ID for bcm4319
Date: Fri, 5 May 2006 03:02:25 +0200
Message-ID: <20060505030225.7928592c@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: bcm43xx-dev@lists.berlios.de, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.polimi.it ([131.175.12.3]:11470 "EHLO polimi.it")
	by vger.kernel.org with ESMTP id S1751525AbWEEBDX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 4 May 2006 21:03:23 -0400
To: "John W. Linville" <linville@tuxdriver.com>,
	Andrew Morton <akpm@osdl.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

bcm4319 is reported to work. This applies to 2.6.17-rc3.

--

Add PCI ID for bcm4319.

Signed-off-by: Stefano Brivio <stefano.brivio@polimi.it>

Index: linux-2.6/drivers/net/wireless/bcm43xx/bcm43xx_main.c
===================================================================
--- linux-2.6.orig/drivers/net/wireless/bcm43xx/bcm43xx_main.c	2006-05-05 00:50:00.370034536 +0200
+++ linux-2.6/drivers/net/wireless/bcm43xx/bcm43xx_main.c	2006-05-05 02:56:42.216378232 +0200
@@ -132,6 +132,8 @@ MODULE_PARM_DESC(fwpostfix, "Postfix for
 	{ PCI_VENDOR_ID_BROADCOM, 0x4307, PCI_ANY_ID, PCI_ANY_ID, 0, 0, 0 },
 		/* Broadcom 4318 802.11b/g */
 	{ PCI_VENDOR_ID_BROADCOM, 0x4318, PCI_ANY_ID, PCI_ANY_ID, 0, 0, 0 },
+	/* Broadcom 4319 802.11a/b/g */
+	{ PCI_VENDOR_ID_BROADCOM, 0x4319, PCI_ANY_ID, PCI_ANY_ID, 0, 0, 0 },
 	/* Broadcom 4306 802.11b/g */
 	{ PCI_VENDOR_ID_BROADCOM, 0x4320, PCI_ANY_ID, PCI_ANY_ID, 0, 0, 0 },
 		/* Broadcom 4306 802.11a */


--
Ciao
Stefano
