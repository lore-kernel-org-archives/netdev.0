From: Kristian Evensen <kristian.evensen@gmail.com>
Subject: [PATCH] net: qmi_wwan: MC73xx interface 10 is not QMI
Date: Mon,  9 Feb 2015 11:17:07 +0100
Message-ID: <1423477027-10869-1-git-send-email-kristian.evensen@gmail.com>
Cc: Kristian Evensen <kristian.evensen@gmail.com>
To: netdev@vger.kernel.org, bjorn@mork.no
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f171.google.com ([209.85.217.171]:58456 "EHLO
	mail-lb0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759233AbbBIKRU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Feb 2015 05:17:20 -0500
Received: by mail-lb0-f171.google.com with SMTP id b6so6164541lbj.2
        for <netdev@vger.kernel.org>; Mon, 09 Feb 2015 02:17:18 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Kristian Evensen <kristian.evensen@gmail.com>

Sierra Wireless MC73xx interface 10 is not usable with QMI, as the interface
does not respond to any QMI messages. We are now left with interface 8 for the
MC73xx, which is consistent with most other Sierra Wireless QMI-devices.

Signed-off-by: Kristian Evensen <kristian.evensen@gmail.com>
---
 drivers/net/usb/qmi_wwan.c | 1 -
 1 file changed, 1 deletion(-)

diff --git a/drivers/net/usb/qmi_wwan.c b/drivers/net/usb/qmi_wwan.c
index 602dc66..197c012 100644
--- a/drivers/net/usb/qmi_wwan.c
+++ b/drivers/net/usb/qmi_wwan.c
@@ -753,7 +753,6 @@ static const struct usb_device_id products[] = {
 	{QMI_FIXED_INTF(0x1199, 0x68a2, 8)},	/* Sierra Wireless MC7710 in QMI mode */
 	{QMI_FIXED_INTF(0x1199, 0x68a2, 19)},	/* Sierra Wireless MC7710 in QMI mode */
 	{QMI_FIXED_INTF(0x1199, 0x68c0, 8)},	/* Sierra Wireless MC73xx */
-	{QMI_FIXED_INTF(0x1199, 0x68c0, 10)},	/* Sierra Wireless MC73xx */
 	{QMI_FIXED_INTF(0x1199, 0x901c, 8)},    /* Sierra Wireless EM7700 */
 	{QMI_FIXED_INTF(0x1199, 0x901f, 8)},    /* Sierra Wireless EM7355 */
 	{QMI_FIXED_INTF(0x1199, 0x9041, 8)},	/* Sierra Wireless MC7305/MC7355 */
-- 
1.9.1
