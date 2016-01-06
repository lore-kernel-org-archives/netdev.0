From: Kristian Evensen <kristian.evensen@gmail.com>
Subject: [PATCH] net: qmi_wwan: Add WeTelecom-WPD600N
Date: Wed,  6 Jan 2016 14:15:50 +0100
Message-ID: <1452086150-14754-1-git-send-email-kristian.evensen@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Kristian Evensen <kristian.evensen@gmail.com>,
	=?UTF-8?q?Bj=C3=B8rn=20Mork?= <bjorn@mork.no>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f171.google.com ([209.85.217.171]:36489 "EHLO
	mail-lb0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751601AbcAFNQI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Jan 2016 08:16:08 -0500
Received: by mail-lb0-f171.google.com with SMTP id oh2so190753549lbb.3
        for <netdev@vger.kernel.org>; Wed, 06 Jan 2016 05:16:07 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Kristian Evensen <kristian.evensen@gmail.com>

The WeTelecom-WPD600N is an LTE module that, in addition to supporting =
most
"normal" bands, also supports LTE over 450MHz. Manual testing showed th=
at
only interface number three replies to QMI messages.

Cc: Bj=C3=B8rn Mork <bjorn@mork.no>
Signed-off-by: Kristian Evensen <kristian.evensen@gmail.com>

---
 drivers/net/usb/qmi_wwan.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/drivers/net/usb/qmi_wwan.c b/drivers/net/usb/qmi_wwan.c
index 9a5be8b..5fccc5a 100644
--- a/drivers/net/usb/qmi_wwan.c
+++ b/drivers/net/usb/qmi_wwan.c
@@ -742,6 +742,7 @@ static const struct usb_device_id products[] =3D {
 	{QMI_FIXED_INTF(0x413c, 0x81a9, 8)},	/* Dell Wireless 5808e Gobi(TM) =
4G LTE Mobile Broadband Card */
 	{QMI_FIXED_INTF(0x413c, 0x81b1, 8)},	/* Dell Wireless 5809e Gobi(TM) =
4G LTE Mobile Broadband Card */
 	{QMI_FIXED_INTF(0x03f0, 0x4e1d, 8)},	/* HP lt4111 LTE/EV-DO/HSPA+ Gob=
i 4G Module */
+	{QMI_FIXED_INTF(0x22de, 0x9061, 3)},	/* WeTelecom WPD-600N */
=20
 	/* 4. Gobi 1000 devices */
 	{QMI_GOBI1K_DEVICE(0x05c6, 0x9212)},	/* Acer Gobi Modem Device */
--=20
2.5.0
