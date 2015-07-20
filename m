From: Pieter Hollants <pieter@hollants.com>
Subject: [PATCH net-next] qmi_wwan: Add support for Dell Wireless 5809e 4G Modem
Date: Mon, 20 Jul 2015 10:14:13 +0200
Message-ID: <1437380053-5444-1-git-send-email-pieter@hollants.com>
Cc: bjorn@mork.no, Pieter Hollants <pieter@hollants.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from koog.hollants.com ([95.156.193.13]:41473 "EHLO
	mail.hollants.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756323AbbGTIU5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 20 Jul 2015 04:20:57 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Added the USB IDs 0x413c:0x81b1 for the "Dell Wireless 5809e Gobi(TM) 4G
LTE Mobile Broadband Card", a Dell-branded Sierra Wireless EM7305 LTE
card in M.2 form factor, used eg. in Dell's Latitude E7540 Notebook
series.

Signed-off-by: Pieter Hollants <pieter@hollants.com>
---
 drivers/net/usb/qmi_wwan.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/drivers/net/usb/qmi_wwan.c b/drivers/net/usb/qmi_wwan.c
index f603f36..f06c687 100644
--- a/drivers/net/usb/qmi_wwan.c
+++ b/drivers/net/usb/qmi_wwan.c
@@ -784,6 +784,7 @@ static const struct usb_device_id products[] = {
 	{QMI_FIXED_INTF(0x413c, 0x81a4, 8)},	/* Dell Wireless 5570e HSPA+ (42Mbps) Mobile Broadband Card */
 	{QMI_FIXED_INTF(0x413c, 0x81a8, 8)},	/* Dell Wireless 5808 Gobi(TM) 4G LTE Mobile Broadband Card */
 	{QMI_FIXED_INTF(0x413c, 0x81a9, 8)},	/* Dell Wireless 5808e Gobi(TM) 4G LTE Mobile Broadband Card */
+	{QMI_FIXED_INTF(0x413c, 0x81b1, 8)},	/* Dell Wireless 5809e Gobi(TM) 4G LTE Mobile Broadband Card */
 	{QMI_FIXED_INTF(0x03f0, 0x581d, 4)},	/* HP lt4112 LTE/HSPA+ Gobi 4G Module (Huawei me906e) */
 
 	/* 4. Gobi 1000 devices */
-- 
2.4.5
