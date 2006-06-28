From: Adrian Bunk <bunk@stusta.de>
Subject: [2.6 patch] drivers/net/irda/mcs7780.c: make struct mcs_driver static
Date: Wed, 28 Jun 2006 18:54:50 +0200
Message-ID: <20060628165450.GS13915@stusta.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Samuel Ortiz <samuel@sortiz.org>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1751482AbWF1RBI@vger.kernel.org>
To: Andrew Morton <akpm@osdl.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch makes a needlessly global struct static.

Signed-off-by: Adrian Bunk <bunk@stusta.de>

---

This patch was already sent on:
- 22 Jun 2006

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
