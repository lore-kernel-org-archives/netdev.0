From: Shahar Havivi <shaharh@redhat.com>
Subject: [PATCH-v2] Added support for usb ethernet (0x0fe6, 0x9700)
Date: Tue, 22 Feb 2011 16:41:11 +0200
Message-ID: <20110222144110.GG2122@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-usb@vger.kernel.org, linux-kernel@vger.kernel.org,
	Greg Kroah-Hartman <gregkh@suse.de>, netdev@vger.kernel.org
To: Peter Korsgaard <jacmet@sunsite.dk>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The device is very similar to (0x0fe6, 0x8101),
And works well with dm9601 driver.

Signed-off-by: Shahar Havivi <shaharh@redhat.com>
---
v2:
Fix Peter Korsgaard comments:
got rid of empty line,
move after the 0x8101 device
---
 drivers/net/usb/dm9601.c |    4 ++++
 1 files changed, 4 insertions(+), 0 deletions(-)

diff --git a/drivers/net/usb/dm9601.c b/drivers/net/usb/dm9601.c
index 02b622e..5002f5b 100644
--- a/drivers/net/usb/dm9601.c
+++ b/drivers/net/usb/dm9601.c
@@ -651,6 +651,10 @@ static const struct usb_device_id products[] = {
 	.driver_info = (unsigned long)&dm9601_info,
 	 },
 	{
+	 USB_DEVICE(0x0fe6, 0x9700),	/* DM9601 USB to Fast Ethernet Adapter */
+	 .driver_info = (unsigned long)&dm9601_info,
+	 },
+	{
 	 USB_DEVICE(0x0a46, 0x9000),	/* DM9000E */
 	 .driver_info = (unsigned long)&dm9601_info,
 	 },
-- 
1.7.4
