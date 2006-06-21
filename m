From: Adrian Bunk <bunk@stusta.de>
Subject: [2.6 patch] drivers/net/irda/mcs7780.c: make struct mcs_driver static
Date: Thu, 22 Jun 2006 01:20:10 +0200
Message-ID: <20060621232010.GS9111@stusta.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailout.stusta.mhn.de ([141.84.69.5]:38411 "HELO
	mailout.stusta.mhn.de") by vger.kernel.org with SMTP
	id S1030456AbWFUXUL (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 21 Jun 2006 19:20:11 -0400
To: Samuel Ortiz <samuel@sortiz.org>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch makes a needlessly global struct static.

Signed-off-by: Adrian Bunk <bunk@stusta.de>

--- linux-2.6.17-mm1-full/drivers/net/irda/mcs7780.c.old	2006-06-22 00:38:41.000000000 +0200
+++ linux-2.6.17-mm1-full/drivers/net/irda/mcs7780.c	2006-06-22 00:38:50.000000000 +0200
@@ -101,7 +101,7 @@
 module_param(transceiver_type, int, 0444);
 MODULE_PARM_DESC(transceiver_type, "IR transceiver type, see mcs7780.h.");
 
-struct usb_driver mcs_driver = {
+static struct usb_driver mcs_driver = {
 	.name = "mcs7780",
 	.probe = mcs_probe,
 	.disconnect = mcs_disconnect,

