From: Jean-Christian de Rivaz <jc@eclis.ch>
Subject: [PATCH] Add CDC-ACM support for the CX93010-2x UCMxx USB Modem
Date: Thu, 11 Oct 2012 00:49:02 +0200
Message-ID: <1349909342-13379-1-git-send-email-jc@eclis.ch>
Cc: netdev@vger.kernel.org, oneukum@suse.de
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from www.eclis.ch ([217.162.2.166]:48576 "EHLO mail.eclis.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932445Ab2JJXQx (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 10 Oct 2012 19:16:53 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This USB V.92/V.32bis Controllered Modem have the USB vendor ID 0x0572
and device ID 0x1340. It need the NO_UNION_NORMAL quirk to be recognized.

Reference:
http://www.conexant.com/servlets/DownloadServlet/DSH-201723-005.pdf?docid=1725&revid=5
See idVendor and idProduct in table 6-1. Device Descriptors

Signed-off-by: Jean-Christian de Rivaz <jc@eclis.ch>
---
 drivers/usb/class/cdc-acm.c |    3 +++
 1 files changed, 3 insertions(+), 0 deletions(-)

diff --git a/drivers/usb/class/cdc-acm.c b/drivers/usb/class/cdc-acm.c
index 36f2be4..981f213 100644
--- a/drivers/usb/class/cdc-acm.c
+++ b/drivers/usb/class/cdc-acm.c
@@ -1551,6 +1551,9 @@ static const struct usb_device_id acm_ids[] = {
 					   Maybe we should define a new
 					   quirk for this. */
 	},
+	{ USB_DEVICE(0x0572, 0x1340), /* Conexant CX93010-2x UCMxx */
+	.driver_info = NO_UNION_NORMAL,
+	},
 	{ USB_DEVICE(0x1bbb, 0x0003), /* Alcatel OT-I650 */
 	.driver_info = NO_UNION_NORMAL, /* reports zero length descriptor */
 	},
-- 
1.7.2.5
