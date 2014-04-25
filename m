From: =?UTF-8?q?Bj=C3=B8rn=20Mork?= <bjorn@mork.no>
Subject: [PATCH net,stable 2/7] net: qmi_wwan: add Sierra Wireless MC73xx
Date: Fri, 25 Apr 2014 19:00:29 +0200
Message-ID: <1398445234-26620-3-git-send-email-bjorn@mork.no>
References: <1398445234-26620-1-git-send-email-bjorn@mork.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-usb@vger.kernel.org,
	=?UTF-8?q?Bj=C3=B8rn=20Mork?= <bjorn@mork.no>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from canardo.mork.no ([148.122.252.1]:34294 "EHLO canardo.mork.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752160AbaDYRAp (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 25 Apr 2014 13:00:45 -0400
In-Reply-To: <1398445234-26620-1-git-send-email-bjorn@mork.no>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom Sierra Wireless' "USB Driver Developer's Guide"

Signed-off-by: Bj=C3=B8rn Mork <bjorn@mork.no>
---
 drivers/net/usb/qmi_wwan.c | 3 +++
 1 file changed, 3 insertions(+)

diff --git a/drivers/net/usb/qmi_wwan.c b/drivers/net/usb/qmi_wwan.c
index f4c9290aa117..60a95ab243d6 100644
--- a/drivers/net/usb/qmi_wwan.c
+++ b/drivers/net/usb/qmi_wwan.c
@@ -730,6 +730,9 @@ static const struct usb_device_id products[] =3D {
 	{QMI_FIXED_INTF(0x114f, 0x68a2, 8)},    /* Sierra Wireless MC7750 */
 	{QMI_FIXED_INTF(0x1199, 0x68a2, 8)},	/* Sierra Wireless MC7710 in QMI=
 mode */
 	{QMI_FIXED_INTF(0x1199, 0x68a2, 19)},	/* Sierra Wireless MC7710 in QM=
I mode */
+	{QMI_FIXED_INTF(0x1199, 0x68c0, 8)},	/* Sierra Wireless MC73xx */
+	{QMI_FIXED_INTF(0x1199, 0x68c0, 10)},	/* Sierra Wireless MC73xx */
+	{QMI_FIXED_INTF(0x1199, 0x68c0, 11)},	/* Sierra Wireless MC73xx */
 	{QMI_FIXED_INTF(0x1199, 0x901c, 8)},    /* Sierra Wireless EM7700 */
 	{QMI_FIXED_INTF(0x1199, 0x901f, 8)},    /* Sierra Wireless EM7355 */
 	{QMI_FIXED_INTF(0x1199, 0x9051, 8)},	/* Netgear AirCard 340U */
--=20
2.0.0.rc0
