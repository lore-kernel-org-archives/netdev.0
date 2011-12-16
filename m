From: Aurelien Jacobs <aurel@gnuage.org>
Subject: [PATCH] asix: new device id
Date: Fri, 16 Dec 2011 21:49:22 +0100
Message-ID: <1324068562-3761-1-git-send-email-aurel@gnuage.org>
References: <20111216.133227.782560339712731597.davem@davemloft.net>
Cc: Aurelien Jacobs <aurel@gnuage.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from gnuage.org ([82.234.153.242]:59823 "EHLO gnuage.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1760696Ab1LPVQj (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 16 Dec 2011 16:16:39 -0500
In-Reply-To: <20111216.133227.782560339712731597.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Adds the device id needed for the USB Ethernet Adapter delivered by
ASUS with their Zenbook.

Signed-off-by: Aurelien Jacobs <aurel@gnuage.org>
---
 drivers/net/usb/asix.c |    4 ++++
 1 files changed, 4 insertions(+), 0 deletions(-)

diff --git a/drivers/net/usb/asix.c b/drivers/net/usb/asix.c
index e6fed4d..e95f0e6 100644
--- a/drivers/net/usb/asix.c
+++ b/drivers/net/usb/asix.c
@@ -1655,6 +1655,10 @@ static const struct usb_device_id	products [] = {
 	// ASIX 88772a
 	USB_DEVICE(0x0db0, 0xa877),
 	.driver_info = (unsigned long) &ax88772_info,
+}, {
+	// Asus USB Ethernet Adapter
+	USB_DEVICE (0x0b95, 0x7e2b),
+	.driver_info = (unsigned long) &ax88772_info,
 },
 	{ },		// END
 };
-- 
1.7.7.3
