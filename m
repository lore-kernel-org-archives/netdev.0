From: Thomas Loo <tloo@saltstorm.net>
Subject: [PATCH] net: cdc_ether.c: Add SE J105i to device whitelist
Date: Wed, 23 Dec 2009 21:56:47 +0100
Message-ID: <1261601807-8385-1-git-send-email-tloo@saltstorm.net>
Cc: Thomas Loo <tloo@saltstorm.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from x380.saltstorm.net ([217.198.148.170]:43347 "EHLO
	mail.saltstorm.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755121AbZLWVEu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Dec 2009 16:04:50 -0500
Received: from localhost.localdomain
	by mail.saltstorm.net with [XMail 1.26 ESMTP Server]
	id <S17BA3B> for <netdev@vger.kernel.org> from <tloo@saltstorm.net>;
	Wed, 23 Dec 2009 21:56:31 +0100
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds the Sony Ericsson J105i (Naite)
mobile phone to the cdc_ether device whitelist,
enabling access to the modem.

I would think more SE models of this generation
(2009Q3) with builtin HSDPA modules also needs
to be added to this list.

Signed-off-by: Thomas Loo <tloo@saltstorm.net>
---
 drivers/net/usb/cdc_ether.c |    5 +++++
 1 files changed, 5 insertions(+), 0 deletions(-)

diff --git a/drivers/net/usb/cdc_ether.c b/drivers/net/usb/cdc_ether.c
index 21e183a..833ba5a 100644
--- a/drivers/net/usb/cdc_ether.c
+++ b/drivers/net/usb/cdc_ether.c
@@ -584,6 +584,11 @@ static const struct usb_device_id	products [] = {
 			USB_CDC_SUBCLASS_MDLM, USB_CDC_PROTO_NONE),
 	.driver_info = (unsigned long) &mbm_info,
 }, {
+	/* Sony Ericsson J105i (Naite) */
+	USB_DEVICE_AND_INTERFACE_INFO(0x0fce, 0xd12d, USB_CLASS_COMM,
+			USB_CDC_SUBCLASS_MDLM, USB_CDC_PROTO_NONE),
+	.driver_info = (unsigned long) &mbm_info,
+}, {
 	/* Toshiba F3507g */
 	USB_DEVICE_AND_INTERFACE_INFO(0x0930, 0x130b, USB_CLASS_COMM,
 			USB_CDC_SUBCLASS_MDLM, USB_CDC_PROTO_NONE),
-- 
1.6.5.5

