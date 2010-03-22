From: Andreas Hartmann <andi@ahash.de>
Subject: [PATCH] kaweth: New USB ID 07c9:b010 Allied Telesyn AT-USB10
Date: Tue, 23 Mar 2010 00:07:46 +0100
Message-ID: <20100323000746.65aaa3db@zed>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-usb@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	Andrew Morton <akpm@linux-foundation.org>
To: Greg Kroah-Hartman <gregkh@suse.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

New USB ID 07c9:b010 Allied Telesyn AT-USB10
Signed-off-by: Andreas Hartmann <andi@ahash.de>
---
This USB Ethernet adapter has the KL5KUSB101B chip and is so far unknown to the
kaweth driver. The device was found working with the patch applied.
--- linux-2.6.34-rc2/drivers/net/usb/kaweth.c.orig      2010-03-20 02:17:57.000000000 +0100
+++ linux-2.6.34-rc2/drivers/net/usb/kaweth.c   2010-03-22 23:30:31.000000000 +0100
@@ -145,6 +145,7 @@ static struct usb_device_id usb_klsi_tab
        { USB_DEVICE(0x0707, 0x0100) }, /* SMC 2202USB */
        { USB_DEVICE(0x07aa, 0x0001) }, /* Correga K.K. */
        { USB_DEVICE(0x07b8, 0x4000) }, /* D-Link DU-E10 */
+       { USB_DEVICE(0x07c9, 0xb010) }, /* Allied Telesyn AT-USB10 */
        { USB_DEVICE(0x0846, 0x1001) }, /* NetGear EA-101 */
        { USB_DEVICE(0x0846, 0x1002) }, /* NetGear EA-101 */
        { USB_DEVICE(0x085a, 0x0008) }, /* PortGear Ethernet Adapter */
