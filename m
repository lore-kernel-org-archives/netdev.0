From: Daniele Palmas <dnlplm@gmail.com>
Subject: [PATCH 1/1] NET: usb: qmi_wwan: add support for Telit LE922A PID 0x1040
Date: Thu,  1 Dec 2016 16:52:05 +0100
Message-ID: <1480607525-23044-2-git-send-email-dnlplm@gmail.com>
References: <1480607525-23044-1-git-send-email-dnlplm@gmail.com>
Cc: netdev@vger.kernel.org, Daniele Palmas <dnlplm@gmail.com>
To: =?UTF-8?q?Bj=C3=B8rn=20Mork?= <bjorn@mork.no>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f66.google.com ([74.125.83.66]:34839 "EHLO
        mail-pg0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1758087AbcLAPw3 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 1 Dec 2016 10:52:29 -0500
Received: by mail-pg0-f66.google.com with SMTP id p66so4988341pga.2
        for <netdev@vger.kernel.org>; Thu, 01 Dec 2016 07:52:29 -0800 (PST)
In-Reply-To: <1480607525-23044-1-git-send-email-dnlplm@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds support for PID 0x1040 of Telit LE922A.

The qmi adapter requires to have DTR set for proper working,
so QMI_WWAN_QUIRK_DTR has been enabled.

Signed-off-by: Daniele Palmas <dnlplm@gmail.com>
---
 drivers/net/usb/qmi_wwan.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/drivers/net/usb/qmi_wwan.c b/drivers/net/usb/qmi_wwan.c
index 3ff76c6..6fe1cdb 100644
--- a/drivers/net/usb/qmi_wwan.c
+++ b/drivers/net/usb/qmi_wwan.c
@@ -894,6 +894,7 @@ static const struct usb_device_id products[] = {
 	{QMI_FIXED_INTF(0x1bbb, 0x0203, 2)},	/* Alcatel L800MA */
 	{QMI_FIXED_INTF(0x2357, 0x0201, 4)},	/* TP-LINK HSUPA Modem MA180 */
 	{QMI_FIXED_INTF(0x2357, 0x9000, 4)},	/* TP-LINK MA260 */
+	{QMI_QUIRK_SET_DTR(0x1bc7, 0x1040, 2)},	/* Telit LE922A */
 	{QMI_FIXED_INTF(0x1bc7, 0x1200, 5)},	/* Telit LE920 */
 	{QMI_FIXED_INTF(0x1bc7, 0x1201, 2)},	/* Telit LE920 */
 	{QMI_FIXED_INTF(0x1c9e, 0x9b01, 3)},	/* XS Stick W100-2 from 4G Systems */
-- 
2.7.4
