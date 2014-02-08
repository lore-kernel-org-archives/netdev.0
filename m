From: Raymond Wanyoike <raymond.wanyoike@gmail.com>
Subject: [RFC] net: qmi_wwan: add ZTE MF667
Date: Sun,  9 Feb 2014 00:01:02 +0300
Message-ID: <1391893262-25092-1-git-send-email-raymond.wanyoike@gmail.com>
Cc: linux-kernel@vger.kernel.org, bjorn@mork.no,
	Raymond Wanyoike <raymond.wanyoike@gmail.com>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The driver description files give these descriptions to the vendor specific
ports on this modem:

 VID_19D2&PID_1270&MI_00: "ZTE MF667 Diagnostics Port"
 VID_19D2&PID_1270&MI_01: "ZTE MF667 AT Port"
 VID_19D2&PID_1270&MI_02: "ZTE MF667 ATExt2 Port"
 VID_19D2&PID_1270&MI_03: "ZTE MF667 ATExt Port"
 VID_19D2&PID_1270&MI_04: "ZTE MF667 USB Modem"
 VID_19D2&PID_1270&MI_05: "ZTE MF667 Network Adapter"

Signed-off-by: Raymond Wanyoike <raymond.wanyoike@gmail.com>
---
 drivers/net/usb/qmi_wwan.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/drivers/net/usb/qmi_wwan.c b/drivers/net/usb/qmi_wwan.c
index 23bdd5b..47b0295 100644
--- a/drivers/net/usb/qmi_wwan.c
+++ b/drivers/net/usb/qmi_wwan.c
@@ -712,6 +712,7 @@ static const struct usb_device_id products[] = {
 	{QMI_FIXED_INTF(0x19d2, 0x1255, 3)},
 	{QMI_FIXED_INTF(0x19d2, 0x1255, 4)},
 	{QMI_FIXED_INTF(0x19d2, 0x1256, 4)},
+	{QMI_FIXED_INTF(0x19d2, 0x1270, 5)},	/* ZTE MF667 */
 	{QMI_FIXED_INTF(0x19d2, 0x1401, 2)},
 	{QMI_FIXED_INTF(0x19d2, 0x1402, 2)},	/* ZTE MF60 */
 	{QMI_FIXED_INTF(0x19d2, 0x1424, 2)},
-- 
1.8.5.4
