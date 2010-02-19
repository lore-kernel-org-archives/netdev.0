From: Torgny Johansson <torgny.johansson@gmail.com>
Subject: [PATCH torvalds-2.6] cdc_ether: new PID for Ericsson C3607w to the whitelist
Date: Fri, 19 Feb 2010 11:58:03 +0100
Message-ID: <201002191158.03712.torgny.johansson@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ew0-f219.google.com ([209.85.219.219]:38957 "EHLO
	mail-ew0-f219.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753888Ab0BSK6M (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 Feb 2010 05:58:12 -0500
Received: by ewy19 with SMTP id 19so7912492ewy.21
        for <netdev@vger.kernel.org>; Fri, 19 Feb 2010 02:58:10 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi!

This patch adds a new vid/pid to the cdc_ether whitelist.

Device added:
- Ericsson Mobile Broadband variant C3607w

Regards
Torgny Johansson

---

Signed-off-by: Torgny Johansson <torgny.johansson@gmail.com>

diff --git a/drivers/net/usb/cdc_ether.c b/drivers/net/usb/cdc_ether.c
index 4f27f02..5f3b9ea 100644
--- a/drivers/net/usb/cdc_ether.c
+++ b/drivers/net/usb/cdc_ether.c
@@ -584,6 +584,11 @@ static const struct usb_device_id	products [] = {
 			USB_CDC_SUBCLASS_MDLM, USB_CDC_PROTO_NONE),
 	.driver_info = (unsigned long) &mbm_info,
 }, {
+	/* Ericsson C3607w ver 2 */
+	USB_DEVICE_AND_INTERFACE_INFO(0x0bdb, 0x190b, 
USB_CLASS_COMM,
+			USB_CDC_SUBCLASS_MDLM, USB_CDC_PROTO_NONE),
+	.driver_info = (unsigned long) &mbm_info,
+}, {
 	/* Toshiba F3507g */
 	USB_DEVICE_AND_INTERFACE_INFO(0x0930, 0x130b, 
USB_CLASS_COMM,
 			USB_CDC_SUBCLASS_MDLM, USB_CDC_PROTO_NONE),
