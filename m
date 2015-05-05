From: Vasily Titskiy <qehgt0-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: [PATCH] drivers/net/usb: Add support for 'Lenovo OneLink Pro Dock'
Date: Tue, 5 May 2015 16:54:07 -0400
Message-ID: <20150505205407.GE22345@ubuntu-build.winmagic.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

This device is sold as 'Lenovo OneLink Pro Dock'.
Chipset is RTL8153 and works with r8152.

Signed-off-by: Vasily Titskiy <qehgt0-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
---
 drivers/net/usb/r8152.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/drivers/net/usb/r8152.c b/drivers/net/usb/r8152.c
index ac4d03b..aafa1a1 100644
--- a/drivers/net/usb/r8152.c
+++ b/drivers/net/usb/r8152.c
@@ -4116,6 +4116,7 @@ static struct usb_device_id rtl8152_table[] = {
        {REALTEK_USB_DEVICE(VENDOR_ID_REALTEK, 0x8153)},
        {REALTEK_USB_DEVICE(VENDOR_ID_SAMSUNG, 0xa101)},
        {REALTEK_USB_DEVICE(VENDOR_ID_LENOVO,  0x7205)},
+       {REALTEK_USB_DEVICE(VENDOR_ID_LENOVO,  0x304f)},
        {}
 };

--
1.9.1

--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
