From: =?UTF-8?q?Bj=C3=B8rn=20Mork?= <bjorn@mork.no>
Subject: [PATCH net,stable] qmi_wwan: new Telewell and Sierra device IDs
Date: Tue, 13 Jun 2017 19:10:18 +0200
Message-ID: <20170613171018.31526-1-bjorn@mork.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Cc: linux-usb@vger.kernel.org, Johan Hovold <johan@kernel.org>,
        Lars Melin <larsm17@gmail.com>, Dan Williams <dcbw@redhat.com>,
        Daniele Palmas <dnlplm@gmail.com>,
        Petr Kloc <petr_kloc@yahoo.com>,
        Teemu Likonen <tlikonen@iki.fi>,
        =?UTF-8?q?Bj=C3=B8rn=20Mork?= <bjorn@mork.no>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from canardo.mork.no ([148.122.252.1]:34071 "EHLO canardo.mork.no"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752337AbdFMRKm (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 13 Jun 2017 13:10:42 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

A new Sierra Wireless EM7305 device ID used in a Toshiba laptop,
and two Longcheer device IDs entries used by Telewell TW-3G HSPA+
branded modems.

Reported-by: Petr Kloc <petr_kloc@yahoo.com>
Reported-by: Teemu Likonen <tlikonen@iki.fi>
Signed-off-by: Bjørn Mork <bjorn@mork.no>
---
The following patch should be backported to v4.9 and later stable kernels to
make this one apply cleanly:

 14cf4a771b30 ("drivers: net: usb: qmi_wwan: add QMI_QUIRK_SET_DTR for Telit PID 0x1201")


 drivers/net/usb/qmi_wwan.c | 4 ++++
 1 file changed, 4 insertions(+)

diff --git a/drivers/net/usb/qmi_wwan.c b/drivers/net/usb/qmi_wwan.c
index 949671ce4039..32a22f4e8356 100644
--- a/drivers/net/usb/qmi_wwan.c
+++ b/drivers/net/usb/qmi_wwan.c
@@ -1192,6 +1192,8 @@ static const struct usb_device_id products[] = {
 	{QMI_FIXED_INTF(0x1199, 0x9056, 8)},	/* Sierra Wireless Modem */
 	{QMI_FIXED_INTF(0x1199, 0x9057, 8)},
 	{QMI_FIXED_INTF(0x1199, 0x9061, 8)},	/* Sierra Wireless Modem */
+	{QMI_FIXED_INTF(0x1199, 0x9063, 8)},	/* Sierra Wireless EM7305 */
+	{QMI_FIXED_INTF(0x1199, 0x9063, 10)},	/* Sierra Wireless EM7305 */
 	{QMI_FIXED_INTF(0x1199, 0x9071, 8)},	/* Sierra Wireless MC74xx */
 	{QMI_FIXED_INTF(0x1199, 0x9071, 10)},	/* Sierra Wireless MC74xx */
 	{QMI_FIXED_INTF(0x1199, 0x9079, 8)},	/* Sierra Wireless EM74xx */
@@ -1206,6 +1208,8 @@ static const struct usb_device_id products[] = {
 	{QMI_FIXED_INTF(0x1bc7, 0x1100, 3)},	/* Telit ME910 */
 	{QMI_FIXED_INTF(0x1bc7, 0x1200, 5)},	/* Telit LE920 */
 	{QMI_QUIRK_SET_DTR(0x1bc7, 0x1201, 2)},	/* Telit LE920, LE920A4 */
+	{QMI_FIXED_INTF(0x1c9e, 0x9801, 3)},	/* Telewell TW-3G HSPA+ */
+	{QMI_FIXED_INTF(0x1c9e, 0x9803, 4)},	/* Telewell TW-3G HSPA+ */
 	{QMI_FIXED_INTF(0x1c9e, 0x9b01, 3)},	/* XS Stick W100-2 from 4G Systems */
 	{QMI_FIXED_INTF(0x0b3c, 0xc000, 4)},	/* Olivetti Olicard 100 */
 	{QMI_FIXED_INTF(0x0b3c, 0xc001, 4)},	/* Olivetti Olicard 120 */
-- 
2.11.0
