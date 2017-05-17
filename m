From: =?UTF-8?q?Bj=C3=B8rn=20Mork?= <bjorn@mork.no>
Subject: [PATCH net,stable] qmi_wwan: add another Lenovo EM74xx device ID
Date: Wed, 17 May 2017 16:31:41 +0200
Message-ID: <20170517143141.28483-1-bjorn@mork.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Cc: linux-usb@vger.kernel.org,
        =?UTF-8?q?Bj=C3=B8rn=20Mork?= <bjorn@mork.no>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from canardo.mork.no ([148.122.252.1]:53399 "EHLO canardo.mork.no"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751398AbdEQOb4 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 17 May 2017 10:31:56 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In their infinite wisdom, and never ending quest for end user frustration,
Lenovo has decided to use a new USB device ID for the wwan modules in
their 2017 laptops.  The actual hardware is still the Sierra Wireless
EM7455 or EM7430, depending on region.

Signed-off-by: Bjørn Mork <bjorn@mork.no>
---
 drivers/net/usb/qmi_wwan.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/drivers/net/usb/qmi_wwan.c b/drivers/net/usb/qmi_wwan.c
index d7165767ca9d..8f923a147fa9 100644
--- a/drivers/net/usb/qmi_wwan.c
+++ b/drivers/net/usb/qmi_wwan.c
@@ -1196,6 +1196,8 @@ static const struct usb_device_id products[] = {
 	{QMI_FIXED_INTF(0x1199, 0x9071, 10)},	/* Sierra Wireless MC74xx */
 	{QMI_FIXED_INTF(0x1199, 0x9079, 8)},	/* Sierra Wireless EM74xx */
 	{QMI_FIXED_INTF(0x1199, 0x9079, 10)},	/* Sierra Wireless EM74xx */
+	{QMI_FIXED_INTF(0x1199, 0x907b, 8)},	/* Sierra Wireless EM74xx */
+	{QMI_FIXED_INTF(0x1199, 0x907b, 10)},	/* Sierra Wireless EM74xx */
 	{QMI_FIXED_INTF(0x1bbb, 0x011e, 4)},	/* Telekom Speedstick LTE II (Alcatel One Touch L100V LTE) */
 	{QMI_FIXED_INTF(0x1bbb, 0x0203, 2)},	/* Alcatel L800MA */
 	{QMI_FIXED_INTF(0x2357, 0x0201, 4)},	/* TP-LINK HSUPA Modem MA180 */
-- 
2.11.0
