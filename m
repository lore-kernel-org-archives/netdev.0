From: Sachin Kamat <sachin.kamat@linaro.org>
Subject: [PATCH 1/1] net: cdc-phonet: Staticize usbpn_probe
Date: Tue, 10 Sep 2013 12:00:55 +0530
Message-ID: <1378794655-18570-1-git-send-email-sachin.kamat@linaro.org>
Cc: davem@davemloft.net, remi@remlab.net, sachin.kamat@linaro.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f49.google.com ([209.85.160.49]:40476 "EHLO
	mail-pb0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754001Ab3IJGs7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Sep 2013 02:48:59 -0400
Received: by mail-pb0-f49.google.com with SMTP id xb4so7113986pbc.36
        for <netdev@vger.kernel.org>; Mon, 09 Sep 2013 23:48:58 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

'usbpn_probe' is referenced only in this file. Make it static.

Signed-off-by: Sachin Kamat <sachin.kamat@linaro.org>
---
 drivers/net/usb/cdc-phonet.c |    3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/drivers/net/usb/cdc-phonet.c b/drivers/net/usb/cdc-phonet.c
index 7d78669..8c44f86 100644
--- a/drivers/net/usb/cdc-phonet.c
+++ b/drivers/net/usb/cdc-phonet.c
@@ -328,7 +328,8 @@ MODULE_DEVICE_TABLE(usb, usbpn_ids);
 
 static struct usb_driver usbpn_driver;
 
-int usbpn_probe(struct usb_interface *intf, const struct usb_device_id *id)
+static int
+usbpn_probe(struct usb_interface *intf, const struct usb_device_id *id)
 {
 	static const char ifname[] = "usbpn%d";
 	const struct usb_cdc_union_desc *union_header = NULL;
-- 
1.7.9.5
