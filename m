From: David Ward <david.ward@ll.mit.edu>
Subject: [PATCH] net: qmi_wwan: Sierra Wireless MC73xx -> Sierra Wireless MC7304/MC7354
Date: Mon, 31 Aug 2015 14:15:14 -0400
Message-ID: <1441044914-20857-1-git-send-email-david.ward@ll.mit.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Ward <david.ward@ll.mit.edu>,
	=?UTF-8?q?Bj=C3=B8rn=20Mork?= <bjorn@mork.no>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from MX1.LL.MIT.EDU ([129.55.12.45]:47461 "EHLO mx1.ll.mit.edu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753807AbbHaSQA (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 31 Aug 2015 14:16:00 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Other Sierra Wireless MC73xx devices exist, with different USB IDs.

Cc: Bj=C3=B8rn Mork <bjorn@mork.no>
Signed-off-by: David Ward <david.ward@ll.mit.edu>
---
 drivers/net/usb/qmi_wwan.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/usb/qmi_wwan.c b/drivers/net/usb/qmi_wwan.c
index 64a60af..7621b68 100644
--- a/drivers/net/usb/qmi_wwan.c
+++ b/drivers/net/usb/qmi_wwan.c
@@ -752,8 +752,8 @@ static const struct usb_device_id products[] =3D {
 	{QMI_FIXED_INTF(0x114f, 0x68a2, 8)},    /* Sierra Wireless MC7750 */
 	{QMI_FIXED_INTF(0x1199, 0x68a2, 8)},	/* Sierra Wireless MC7710 in QMI=
 mode */
 	{QMI_FIXED_INTF(0x1199, 0x68a2, 19)},	/* Sierra Wireless MC7710 in QM=
I mode */
-	{QMI_FIXED_INTF(0x1199, 0x68c0, 8)},	/* Sierra Wireless MC73xx */
-	{QMI_FIXED_INTF(0x1199, 0x68c0, 10)},	/* Sierra Wireless MC73xx */
+	{QMI_FIXED_INTF(0x1199, 0x68c0, 8)},	/* Sierra Wireless MC7304/MC7354=
 */
+	{QMI_FIXED_INTF(0x1199, 0x68c0, 10)},	/* Sierra Wireless MC7304/MC735=
4 */
 	{QMI_FIXED_INTF(0x1199, 0x901c, 8)},    /* Sierra Wireless EM7700 */
 	{QMI_FIXED_INTF(0x1199, 0x901f, 8)},    /* Sierra Wireless EM7355 */
 	{QMI_FIXED_INTF(0x1199, 0x9041, 8)},	/* Sierra Wireless MC7305/MC7355=
 */
--=20
1.7.1
