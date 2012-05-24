From: =?UTF-8?q?Bj=C3=B8rn=20Mork?= <bjorn@mork.no>
Subject: [PATCH] net: qmi_wwan: Add Sierra Wireless device IDs
Date: Thu, 24 May 2012 11:19:32 +0200
Message-ID: <1337851172-28549-1-git-send-email-bjorn@mork.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-usb@vger.kernel.org,
	=?UTF-8?q?Bj=C3=B8rn=20Mork?= <bjorn@mork.no>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from canardo.mork.no ([148.122.252.1]:47238 "EHLO canardo.mork.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754359Ab2EXJTg (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 24 May 2012 05:19:36 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Some additional Gobi3K IDs found in the BSD/GPL licensed
out-of-tree GobiNet driver from Sierra Wireless.

Signed-off-by: Bj=C3=B8rn Mork <bjorn@mork.no>
---
 drivers/net/usb/qmi_wwan.c |    2 ++
 1 files changed, 2 insertions(+), 0 deletions(-)

diff --git a/drivers/net/usb/qmi_wwan.c b/drivers/net/usb/qmi_wwan.c
index 380dbea..3b20678 100644
--- a/drivers/net/usb/qmi_wwan.c
+++ b/drivers/net/usb/qmi_wwan.c
@@ -547,6 +547,8 @@ static const struct usb_device_id products[] =3D {
 	{QMI_GOBI_DEVICE(0x16d8, 0x8002)},	/* CMDTech Gobi 2000 Modem device =
(VU922) */
 	{QMI_GOBI_DEVICE(0x05c6, 0x9205)},	/* Gobi 2000 Modem device */
 	{QMI_GOBI_DEVICE(0x1199, 0x9013)},	/* Sierra Wireless Gobi 3000 Modem=
 device (MC8355) */
+	{QMI_GOBI_DEVICE(0x1199, 0x9015)},	/* Sierra Wireless Gobi 3000 Modem=
 device */
+	{QMI_GOBI_DEVICE(0x1199, 0x9019)},	/* Sierra Wireless Gobi 3000 Modem=
 device */
 	{ }					/* END */
 };
 MODULE_DEVICE_TABLE(usb, products);
--=20
1.7.2.5
