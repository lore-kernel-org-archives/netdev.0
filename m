From: Enrico Mioso <mrkiko.rs-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: [PATCH V2] qmi_wwan: add ONDA MT689DC device ID (fwd)
Date: Sat, 29 Jun 2013 15:39:19 +0200 (CEST)
Message-ID: <alpine.LNX.2.02.1306291536160.3968@eeeadesso>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Cc: linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, scuall8907-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org
To: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Another QMI-speaking device by ZTE, re-branded by ONDA!

I'm connected ovr this device's QMI interface right now, so I can say I tested
it! :)

Note: a follow-up patch was posted to the linux-usb mailing list, to prevent 
the option driver from binding to the device's QMI interface, making it 
unusable.

Signed-off-by: Enrico Mioso <mrkiko.rs-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>


diff --git a/drivers/net/usb/qmi_wwan.c b/drivers/net/usb/qmi_wwan.c
index 5645921..d793ee9 100644
--- a/drivers/net/usb/qmi_wwan.c
+++ b/drivers/net/usb/qmi_wwan.c
@@ -523,6 +523,7 @@ static const struct usb_device_id products[] = {
  	{QMI_FIXED_INTF(0x19d2, 0x0002, 1)},
  	{QMI_FIXED_INTF(0x19d2, 0x0012, 1)},
  	{QMI_FIXED_INTF(0x19d2, 0x0017, 3)},
+	{QMI_FIXED_INTF(0x19d2, 0x0019, 3)}, /* ONDA MT689DC */
  	{QMI_FIXED_INTF(0x19d2, 0x0021, 4)},
  	{QMI_FIXED_INTF(0x19d2, 0x0025, 1)},
  	{QMI_FIXED_INTF(0x19d2, 0x0031, 4)},
--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
