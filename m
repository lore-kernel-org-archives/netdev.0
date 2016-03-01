From: =?UTF-8?q?Bj=C3=B8rn=20Mork?= <bjorn@mork.no>
Subject: [PATCH net,stable] qmi_wwan: add Sierra Wireless EM74xx device ID
Date: Tue,  1 Mar 2016 14:31:02 +0100
Message-ID: <1456839062-31184-1-git-send-email-bjorn@mork.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-usb@vger.kernel.org,
	=?UTF-8?q?Bj=C3=B8rn=20Mork?= <bjorn@mork.no>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from canardo.mork.no ([148.122.252.1]:36327 "EHLO canardo.mork.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753506AbcCANbV (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 1 Mar 2016 08:31:21 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The MC74xx and EM74xx modules use different IDs by default, according
to the Lenovo EM7455 driver for Windows.

Signed-off-by: Bj=C3=B8rn Mork <bjorn@mork.no>
---
 drivers/net/usb/qmi_wwan.c | 6 ++++--
 1 file changed, 4 insertions(+), 2 deletions(-)

diff --git a/drivers/net/usb/qmi_wwan.c b/drivers/net/usb/qmi_wwan.c
index 4ce4ec16e968..a3a4ccf7cf52 100644
--- a/drivers/net/usb/qmi_wwan.c
+++ b/drivers/net/usb/qmi_wwan.c
@@ -861,8 +861,10 @@ static const struct usb_device_id products[] =3D {
 	{QMI_FIXED_INTF(0x1199, 0x9056, 8)},	/* Sierra Wireless Modem */
 	{QMI_FIXED_INTF(0x1199, 0x9057, 8)},
 	{QMI_FIXED_INTF(0x1199, 0x9061, 8)},	/* Sierra Wireless Modem */
-	{QMI_FIXED_INTF(0x1199, 0x9071, 8)},	/* Sierra Wireless MC74xx/EM74xx=
 */
-	{QMI_FIXED_INTF(0x1199, 0x9071, 10)},	/* Sierra Wireless MC74xx/EM74x=
x */
+	{QMI_FIXED_INTF(0x1199, 0x9071, 8)},	/* Sierra Wireless MC74xx */
+	{QMI_FIXED_INTF(0x1199, 0x9071, 10)},	/* Sierra Wireless MC74xx */
+	{QMI_FIXED_INTF(0x1199, 0x9079, 8)},	/* Sierra Wireless EM74xx */
+	{QMI_FIXED_INTF(0x1199, 0x9079, 10)},	/* Sierra Wireless EM74xx */
 	{QMI_FIXED_INTF(0x1bbb, 0x011e, 4)},	/* Telekom Speedstick LTE II (Al=
catel One Touch L100V LTE) */
 	{QMI_FIXED_INTF(0x1bbb, 0x0203, 2)},	/* Alcatel L800MA */
 	{QMI_FIXED_INTF(0x2357, 0x0201, 4)},	/* TP-LINK HSUPA Modem MA180 */
--=20
2.1.4
