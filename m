From: bora.sahin@ttnet.net.tr
Subject: [PATCH 4/12] smc911x: PRINT_PKT doesnt count on odd remainder
Date: Wed, 13 Sep 2006 20:54:06 +0300
Message-ID: <200609132054.06704.bora.sahin@ttnet.net.tr>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Dustin McIntire <dustin@sensoria.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.ttnet.net.tr ([212.175.13.129]:50809 "EHLO
	fep03.ttnet.net.tr") by vger.kernel.org with ESMTP id S1751048AbWIMSen
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 13 Sep 2006 14:34:43 -0400
To: netdev@vger.kernel.org
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


PRINT_PKT doesnt count on odd remainder...

Signed-off-by: Bora Sahin <bora.sahin@ttnet.net.tr>

Index: linux-2.6.18-rc4/drivers/net/smc911x.c
===================================================================
--- linux-2.6.18-rc4.orig/drivers/net/smc911x.c	2006-08-06 21:20:11.000000000 +0300
+++ linux-2.6.18-rc4/drivers/net/smc911x.c	2006-09-04 13:54:26.621458832 +0300
@@ -202,6 +202,7 @@
 		b = *buf++;
 		printk("%02x%02x ", a, b);
 	}
+	if (remainder & 1) printk("%02x", *buf);
 	printk("\n");
 }
 #else
