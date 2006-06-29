From: Samuel Ortiz <samuel@sortiz.org>
Subject: [PATCH] [IrDA] MCS7780 usb_driver struct should be static
Date: Thu, 29 Jun 2006 08:12:36 +0300
Message-ID: <20060629051236.GA31100@sortiz.org>
Reply-To: Samuel Ortiz <samuel@sortiz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, irda-users@lists.sourceforge.net,
	bunk@stusta.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.pp.htv.fi ([213.243.153.35]:28602 "EHLO smtp2.pp.htv.fi")
	by vger.kernel.org with ESMTP id S1751580AbWF1WBT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 28 Jun 2006 18:01:19 -0400
To: "David S. Miller" <davem@davemloft.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Dave,

This patch makes a needlessly global struct static.

Signed-off-by: Adrian Bunk <bunk@stusta.de>
Signed-off-by: Samuel Ortiz <samuel@sortiz.org>
---
 drivers/net/irda/mcs7780.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/irda/mcs7780.c b/drivers/net/irda/mcs7780.c
index 754297f..47f6f64 100644
--- a/drivers/net/irda/mcs7780.c
+++ b/drivers/net/irda/mcs7780.c
@@ -101,7 +101,7 @@ static int transceiver_type = MCS_TSC_VI
 module_param(transceiver_type, int, 0444);
 MODULE_PARM_DESC(transceiver_type, "IR transceiver type, see mcs7780.h.");
 
-struct usb_driver mcs_driver = {
+static struct usb_driver mcs_driver = {
 	.name = "mcs7780",
 	.probe = mcs_probe,
 	.disconnect = mcs_disconnect,
-- 
1.4.0

