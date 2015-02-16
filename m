From: Ben Shelton <ben.shelton@ni.com>
Subject: [PATCH] usb: plusb: Add support for National Instruments host-to-host cable
Date: Mon, 16 Feb 2015 13:47:06 -0600
Message-ID: <1424116026-27869-1-git-send-email-ben.shelton@ni.com>
Cc: Ben Shelton <ben.shelton@ni.com>
To: linux-usb@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The National Instruments USB Host-to-Host Cable is based on the Prolific
PL-25A1 chipset.  Add its VID/PID so the plusb driver will recognize it.

Signed-off-by: Ben Shelton <ben.shelton@ni.com>
---
 drivers/net/usb/plusb.c | 5 +++++
 1 file changed, 5 insertions(+)

diff --git a/drivers/net/usb/plusb.c b/drivers/net/usb/plusb.c
index 3d18bb0..1bfe0fc 100644
--- a/drivers/net/usb/plusb.c
+++ b/drivers/net/usb/plusb.c
@@ -134,6 +134,11 @@ static const struct usb_device_id	products [] = {
 }, {
 	USB_DEVICE(0x050d, 0x258a),     /* Belkin F5U258/F5U279 (PL-25A1) */
 	.driver_info =  (unsigned long) &prolific_info,
+}, {
+	USB_DEVICE(0x3923, 0x7825),     /* National Instruments USB
+					 * Host-to-Host Cable
+					 */
+	.driver_info =  (unsigned long) &prolific_info,
 },
 
 	{ },		// END
-- 
2.3.0
