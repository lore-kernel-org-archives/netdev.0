From: Marek Vasut <marek.vasut@gmail.com>
Subject: [PATCH] ASIX: Add AX88772B USB ID
Date: Wed, 20 Jul 2011 17:57:04 +0200
Message-ID: <1311177424-19308-1-git-send-email-marek.vasut@gmail.com>
Cc: netdev@vger.kernel.org, linux-usb@vger.kernel.org, gregkh@suse.de,
	Marek Vasut <marek.vasut@gmail.com>
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This device can be found in Acer Iconia TAB W500 tablet dock.

Signed-off-by: Marek Vasut <marek.vasut@gmail.com>
---
 drivers/net/usb/asix.c |    4 ++++
 1 files changed, 4 insertions(+), 0 deletions(-)

diff --git a/drivers/net/usb/asix.c b/drivers/net/usb/asix.c
index 6998aa6..5250288 100644
--- a/drivers/net/usb/asix.c
+++ b/drivers/net/usb/asix.c
@@ -1502,6 +1502,10 @@ static const struct usb_device_id	products [] = {
 	USB_DEVICE (0x04f1, 0x3008),
 	.driver_info = (unsigned long) &ax8817x_info,
 }, {
+	// ASIX AX88772B 10/100
+	USB_DEVICE (0x0b95, 0x772b),
+	.driver_info = (unsigned long) &ax88772_info,
+}, {
 	// ASIX AX88772 10/100
 	USB_DEVICE (0x0b95, 0x7720),
 	.driver_info = (unsigned long) &ax88772_info,
-- 
1.7.5.3
