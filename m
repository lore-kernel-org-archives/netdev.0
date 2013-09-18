From: Sachin Kamat <sachin.kamat@linaro.org>
Subject: [PATCH Resend 1/3] net: cdc-phonet: Staticize usbpn_probe
Date: Wed, 18 Sep 2013 08:59:59 +0530
Message-ID: <1379475001-24505-1-git-send-email-sachin.kamat@linaro.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net, sachin.kamat@linaro.org,
	=?UTF-8?q?R=C3=A9mi=20Denis-Courmont?= <remi@remlab.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f179.google.com ([209.85.192.179]:58023 "EHLO
	mail-pd0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751020Ab3IRDsX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Sep 2013 23:48:23 -0400
Received: by mail-pd0-f179.google.com with SMTP id v10so6460225pde.24
        for <netdev@vger.kernel.org>; Tue, 17 Sep 2013 20:48:22 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

'usbpn_probe' is referenced only in this file. Make it static.

Signed-off-by: Sachin Kamat <sachin.kamat@linaro.org>
Acked-by: R=C3=A9mi Denis-Courmont <remi@remlab.net>
Cc: R=C3=A9mi Denis-Courmont <remi@remlab.net>
---
 drivers/net/usb/cdc-phonet.c |    3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/drivers/net/usb/cdc-phonet.c b/drivers/net/usb/cdc-phonet.=
c
index 7d78669..8c44f86 100644
--- a/drivers/net/usb/cdc-phonet.c
+++ b/drivers/net/usb/cdc-phonet.c
@@ -328,7 +328,8 @@ MODULE_DEVICE_TABLE(usb, usbpn_ids);
=20
 static struct usb_driver usbpn_driver;
=20
-int usbpn_probe(struct usb_interface *intf, const struct usb_device_id=
 *id)
+static int
+usbpn_probe(struct usb_interface *intf, const struct usb_device_id *id=
)
 {
 	static const char ifname[] =3D "usbpn%d";
 	const struct usb_cdc_union_desc *union_header =3D NULL;
--=20
1.7.9.5
