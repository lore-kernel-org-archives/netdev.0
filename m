From: akpm@linux-foundation.org
Subject: [patch for 2.6.28? 1/1] bluetooth: Dell Wireless 365 requires reset quirk
Date: Mon, 01 Dec 2008 14:01:05 -0800
Message-ID: <200812012201.mB1M155p001654@imap1.linux-foundation.org>
Cc: linux-bluetooth@vger.kernel.org, netdev@vger.kernel.org,
	akpm@linux-foundation.org, mario_limonciello@dell.com,
	hidave.darkstar@gmail.com, marcel@holtmann.org, stable@kernel.org,
	tim.gardner@canonical.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:42024 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751059AbYLAWCB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 1 Dec 2008 17:02:01 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mario Limonciello <mario_limonciello@dell.com>

This patch causes the BT365 to be reset when the driver is loaded. 
Without it, the machine is unable to connect to other devices or to scan
for devices.

Signed-off-by: Mario Limonciello <mario_limonciello@dell.com>
Signed-off-by: Tim Gardner <tim.gardner@canonical.com>
Cc: Marcel Holtmann <marcel@holtmann.org>
Cc: Dave Young <hidave.darkstar@gmail.com>
Cc: <stable@kernel.org>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
---

 drivers/bluetooth/btusb.c |    3 +++
 1 file changed, 3 insertions(+)

diff -puN drivers/bluetooth/btusb.c~bluetooth-dell-wireless-365-requires-reset-quirk drivers/bluetooth/btusb.c
--- a/drivers/bluetooth/btusb.c~bluetooth-dell-wireless-365-requires-reset-quirk
+++ a/drivers/bluetooth/btusb.c
@@ -125,6 +125,9 @@ static struct usb_device_id blacklist_ta
 	/* Dell laptop with Broadcom chip */
 	{ USB_DEVICE(0x413c, 0x8126), .driver_info = BTUSB_RESET | BTUSB_WRONG_SCO_MTU },
 
+	/* Dell Wireless 365 */
+	{ USB_DEVICE(0x413c, 0x8160), .driver_info = BTUSB_RESET },
+
 	/* Dell Wireless 370 */
 	{ USB_DEVICE(0x413c, 0x8156), .driver_info = BTUSB_RESET | BTUSB_WRONG_SCO_MTU },
 
_
