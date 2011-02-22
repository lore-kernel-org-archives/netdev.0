From: Shahar Havivi <shaharh@redhat.com>
Subject: [PATCH] USB 10/100 RJ45 Ethernet Network Adapter
Date: Tue, 22 Feb 2011 16:07:10 +0200
Message-ID: <20110222140705.GA6055@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Peter Korsgaard <jacmet@sunsite.dk>,
	Greg Kroah-Hartman <gregkh@suse.de>, netdev@vger.kernel.org
To: linux-usb@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The device is very similar to (0x0fe6, 0x8101),
And works well with dm9601 driver.
---
 drivers/net/usb/dm9601.c |    5 +++++
 1 files changed, 5 insertions(+), 0 deletions(-)

diff --git a/drivers/net/usb/dm9601.c b/drivers/net/usb/dm9601.c
index 02b622e..2d1c8ae 100644
--- a/drivers/net/usb/dm9601.c
+++ b/drivers/net/usb/dm9601.c
@@ -654,6 +654,11 @@ static const struct usb_device_id products[] = {
 	 USB_DEVICE(0x0a46, 0x9000),	/* DM9000E */
 	 .driver_info = (unsigned long)&dm9601_info,
 	 },
+	{
+	 USB_DEVICE(0x0fe6, 0x9700),	/* DM9601 USB to Fast Ethernet Adapter */
+
+	 .driver_info = (unsigned long)&dm9601_info,
+	 },
 	{},			// END
 };
 
-- 
1.7.3.4
