From: Sachin Kamat <sachin.kamat@linaro.org>
Subject: [PATCH v2 1/1] net: cdc-phonet: Staticize usbpn_probe
Date: Thu, 19 Sep 2013 12:15:26 +0530
Message-ID: <1379573126-4879-1-git-send-email-sachin.kamat@linaro.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net, sachin.kamat@linaro.org,
	=?UTF-8?q?R=C3=A9mi=20Denis-Courmont?= <remi@remlab.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f41.google.com ([209.85.160.41]:35883 "EHLO
	mail-pb0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752606Ab3ISGpO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Sep 2013 02:45:14 -0400
Received: by mail-pb0-f41.google.com with SMTP id rp2so8060865pbb.28
        for <netdev@vger.kernel.org>; Wed, 18 Sep 2013 23:45:13 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

'usbpn_probe' is referenced only in this file. Make it static.

Signed-off-by: Sachin Kamat <sachin.kamat@linaro.org>
Acked-by: R=C3=A9mi Denis-Courmont <remi@remlab.net>
Cc: R=C3=A9mi Denis-Courmont <remi@remlab.net>
---
 drivers/net/usb/cdc-phonet.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/usb/cdc-phonet.c b/drivers/net/usb/cdc-phonet.=
c
index 7d78669..6358d42 100644
--- a/drivers/net/usb/cdc-phonet.c
+++ b/drivers/net/usb/cdc-phonet.c
@@ -328,7 +328,7 @@ MODULE_DEVICE_TABLE(usb, usbpn_ids);
=20
 static struct usb_driver usbpn_driver;
=20
-int usbpn_probe(struct usb_interface *intf, const struct usb_device_id=
 *id)
+static int usbpn_probe(struct usb_interface *intf, const struct usb_de=
vice_id *id)
 {
 	static const char ifname[] =3D "usbpn%d";
 	const struct usb_cdc_union_desc *union_header =3D NULL;
--=20
1.7.9.5
