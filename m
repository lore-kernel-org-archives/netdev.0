From: David Ward <david.ward@ll.mit.edu>
Subject: [PATCH] net: qmi_wwan: add HP lt4111 LTE/EV-DO/HSPA+ Gobi 4G Module
Date: Sat, 15 Aug 2015 20:12:30 -0400
Message-ID: <1439683950-11429-1-git-send-email-david.ward@ll.mit.edu>
Cc: David Ward <david.ward@ll.mit.edu>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from MX1.LL.MIT.EDU ([129.55.12.45]:55436 "EHLO mx1.ll.mit.edu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752040AbbHPAMp (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 15 Aug 2015 20:12:45 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is an HP-branded Sierra Wireless EM7355:
https://bugzilla.redhat.com/show_bug.cgi?id=1223646#c2

Signed-off-by: David Ward <david.ward@ll.mit.edu>
---
 drivers/net/usb/qmi_wwan.c |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/drivers/net/usb/qmi_wwan.c b/drivers/net/usb/qmi_wwan.c
index 9d43460..64a60af 100644
--- a/drivers/net/usb/qmi_wwan.c
+++ b/drivers/net/usb/qmi_wwan.c
@@ -785,6 +785,7 @@ static const struct usb_device_id products[] = {
 	{QMI_FIXED_INTF(0x413c, 0x81a4, 8)},	/* Dell Wireless 5570e HSPA+ (42Mbps) Mobile Broadband Card */
 	{QMI_FIXED_INTF(0x413c, 0x81a8, 8)},	/* Dell Wireless 5808 Gobi(TM) 4G LTE Mobile Broadband Card */
 	{QMI_FIXED_INTF(0x413c, 0x81a9, 8)},	/* Dell Wireless 5808e Gobi(TM) 4G LTE Mobile Broadband Card */
+	{QMI_FIXED_INTF(0x03f0, 0x4e1d, 8)},	/* HP lt4111 LTE/EV-DO/HSPA+ Gobi 4G Module */
 	{QMI_FIXED_INTF(0x03f0, 0x581d, 4)},	/* HP lt4112 LTE/HSPA+ Gobi 4G Module (Huawei me906e) */
 
 	/* 4. Gobi 1000 devices */
-- 
1.7.1
