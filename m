From: Kristian Evensen <kristian.evensen@gmail.com>
Subject: [PATCH] net: qmi_wwan: Add SIMCom 7230E
Date: Thu,  7 Jan 2016 16:41:33 +0100
Message-ID: <1452181293-32703-1-git-send-email-kristian.evensen@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Kristian Evensen <kristian.evensen@gmail.com>,
	=?UTF-8?q?Bj=C3=B8rn=20Mork?= <bjorn@mork.no>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f44.google.com ([209.85.215.44]:34940 "EHLO
	mail-lf0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751031AbcAGPlp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Jan 2016 10:41:45 -0500
Received: by mail-lf0-f44.google.com with SMTP id c192so158382825lfe.2
        for <netdev@vger.kernel.org>; Thu, 07 Jan 2016 07:41:44 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Kristian Evensen <kristian.evensen@gmail.com>

SIMCom 7230E is a QMI LTE module with support for most "normal" bands.
Manual testing has showed that only interface five works.

Cc: Bj=C3=B8rn Mork <bjorn@mork.no>
Signed-off-by: Kristian Evensen <kristian.evensen@gmail.com>
---
 drivers/net/usb/qmi_wwan.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/drivers/net/usb/qmi_wwan.c b/drivers/net/usb/qmi_wwan.c
index 5fccc5a..772b9d0 100644
--- a/drivers/net/usb/qmi_wwan.c
+++ b/drivers/net/usb/qmi_wwan.c
@@ -743,6 +743,7 @@ static const struct usb_device_id products[] =3D {
 	{QMI_FIXED_INTF(0x413c, 0x81b1, 8)},	/* Dell Wireless 5809e Gobi(TM) =
4G LTE Mobile Broadband Card */
 	{QMI_FIXED_INTF(0x03f0, 0x4e1d, 8)},	/* HP lt4111 LTE/EV-DO/HSPA+ Gob=
i 4G Module */
 	{QMI_FIXED_INTF(0x22de, 0x9061, 3)},	/* WeTelecom WPD-600N */
+	{QMI_FIXED_INTF(0x1e0e, 0x9001, 5)},	/* SIMCom 7230E */
=20
 	/* 4. Gobi 1000 devices */
 	{QMI_GOBI1K_DEVICE(0x05c6, 0x9212)},	/* Acer Gobi Modem Device */
--=20
2.5.0
