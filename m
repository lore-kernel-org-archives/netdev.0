From: Dan Williams <dcbw@redhat.com>
Subject: [PATCH] qmi_wwan: add various Novatel Gobi1K IDs
Date: Thu, 20 Jun 2013 16:10:59 -0500
Message-ID: <1371762659.10995.52.camel@dcbw.foobar.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: =?ISO-8859-1?Q?Bj=F8rn?= Mork <bjorn@mork.no>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:2993 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758080Ab3FTVJ1 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 20 Jun 2013 17:09:27 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Found in the Windows INF files while investigating the
Novatel/Verizon USB-1000 device.  The USB-1000 is verified as
a Gobi1K device and works with QMI after loading appropriate
firmware.

Signed-off-by: Dan Williams <dcbw@redhat.com>
---
diff --git a/drivers/net/usb/qmi_wwan.c b/drivers/net/usb/qmi_wwan.c
index cf887c2..4d6b98f 100644
--- a/drivers/net/usb/qmi_wwan.c
+++ b/drivers/net/usb/qmi_wwan.c
@@ -588,7 +588,13 @@ static const struct usb_device_id products[] = {
 	{QMI_GOBI1K_DEVICE(0x03f0, 0x1f1d)},	/* HP un2400 Gobi Modem Device */
 	{QMI_GOBI1K_DEVICE(0x04da, 0x250d)},	/* Panasonic Gobi Modem device */
 	{QMI_GOBI1K_DEVICE(0x413c, 0x8172)},	/* Dell Gobi Modem device */
-	{QMI_GOBI1K_DEVICE(0x1410, 0xa001)},	/* Novatel Gobi Modem device */
+	{QMI_GOBI1K_DEVICE(0x1410, 0xa001)},	/* Novatel/Verizon USB-1000 */
+	{QMI_GOBI1K_DEVICE(0x1410, 0xa002)},	/* Novatel Gobi Modem device */
+	{QMI_GOBI1K_DEVICE(0x1410, 0xa003)},	/* Novatel Gobi Modem device */
+	{QMI_GOBI1K_DEVICE(0x1410, 0xa004)},	/* Novatel Gobi Modem device */
+	{QMI_GOBI1K_DEVICE(0x1410, 0xa005)},	/* Novatel Gobi Modem device */
+	{QMI_GOBI1K_DEVICE(0x1410, 0xa006)},	/* Novatel Gobi Modem device */
+	{QMI_GOBI1K_DEVICE(0x1410, 0xa007)},	/* Novatel Gobi Modem device */
 	{QMI_GOBI1K_DEVICE(0x0b05, 0x1776)},	/* Asus Gobi Modem device */
 	{QMI_GOBI1K_DEVICE(0x19d2, 0xfff3)},	/* ONDA Gobi Modem device */
 	{QMI_GOBI1K_DEVICE(0x05c6, 0x9001)},	/* Generic Gobi Modem device */
