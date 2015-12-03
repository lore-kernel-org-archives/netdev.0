From: =?UTF-8?q?Bj=C3=B8rn=20Mork?= <bjorn@mork.no>
Subject: [PATCH 2/6] net: qmi_wwan: remove 1199:9070 device id
Date: Thu,  3 Dec 2015 19:24:19 +0100
Message-ID: <1449167063-22703-3-git-send-email-bjorn@mork.no>
References: <1449167063-22703-1-git-send-email-bjorn@mork.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-usb@vger.kernel.org, Marcel Holtmann <marcel@holtmann.org>,
	Oliver Neukum <oneukum@suse.com>,
	Aleksander Morgado <aleksander@aleksander.es>,
	Dan Williams <dcbw@redhat.com>,
	=?UTF-8?q?Bj=C3=B8rn=20Mork?= <bjorn@mork.no>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from canardo.mork.no ([148.122.252.1]:54996 "EHLO canardo.mork.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752239AbbLCSZI (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 3 Dec 2015 13:25:08 -0500
In-Reply-To: <1449167063-22703-1-git-send-email-bjorn@mork.no>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This turned out to be a bootloader device ID.  No need for
that in this driver.  It will only provide a single serial
function.

Signed-off-by: Bj=C3=B8rn Mork <bjorn@mork.no>
---
 drivers/net/usb/qmi_wwan.c | 2 --
 1 file changed, 2 deletions(-)

diff --git a/drivers/net/usb/qmi_wwan.c b/drivers/net/usb/qmi_wwan.c
index fc9dd452a3b5..e3727b66d850 100644
--- a/drivers/net/usb/qmi_wwan.c
+++ b/drivers/net/usb/qmi_wwan.c
@@ -753,8 +753,6 @@ static const struct usb_device_id products[] =3D {
 	{QMI_FIXED_INTF(0x1199, 0x9056, 8)},	/* Sierra Wireless Modem */
 	{QMI_FIXED_INTF(0x1199, 0x9057, 8)},
 	{QMI_FIXED_INTF(0x1199, 0x9061, 8)},	/* Sierra Wireless Modem */
-	{QMI_FIXED_INTF(0x1199, 0x9070, 8)},	/* Sierra Wireless MC74xx/EM74xx=
 */
-	{QMI_FIXED_INTF(0x1199, 0x9070, 10)},	/* Sierra Wireless MC74xx/EM74x=
x */
 	{QMI_FIXED_INTF(0x1199, 0x9071, 8)},	/* Sierra Wireless MC74xx/EM74xx=
 */
 	{QMI_FIXED_INTF(0x1199, 0x9071, 10)},	/* Sierra Wireless MC74xx/EM74x=
x */
 	{QMI_FIXED_INTF(0x1bbb, 0x011e, 4)},	/* Telekom Speedstick LTE II (Al=
catel One Touch L100V LTE) */
--=20
2.1.4
