From: Larry Finger <Larry.Finger@lwfinger.net>
Subject: [PATCH] staging: rtl8712: Add device ID for Sitecom WLA2100
Date: Sun, 18 Oct 2015 22:14:48 -0500
Message-ID: <1445224488-3036-1-git-send-email-Larry.Finger@lwfinger.net>
Cc: netdev@vger.kernel.org, devel@driverdev.osuosl.org,
	Larry Finger <Larry.Finger@lwfinger.net>,
	Frans van de Wiel <fvdw@fvdw.eu>,
	Stable <stable@vger.kernel.org>
To: gregkh@linuxfoundation.org
Return-path: <stable-owner@vger.kernel.org>
Sender: stable-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This adds the USB ID for the Sitecom WLA2100. The Windows 10 inf file
was checked to verify that the addition is correct.

Reported-by: Frans van de Wiel <fvdw@fvdw.eu>
Signed-off-by: Larry Finger <Larry.Finger@lwfinger.net>
Cc: Frans van de Wiel <fvdw@fvdw.eu>
Cc: Stable <stable@vger.kernel.org> [All stable versions]
---
 drivers/staging/rtl8712/usb_intf.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/drivers/staging/rtl8712/usb_intf.c b/drivers/staging/rtl8712/usb_intf.c
index f8b5b33..943a0e2 100644
--- a/drivers/staging/rtl8712/usb_intf.c
+++ b/drivers/staging/rtl8712/usb_intf.c
@@ -144,6 +144,7 @@ static struct usb_device_id rtl871x_usb_id_tbl[] = {
 	{USB_DEVICE(0x0DF6, 0x0058)},
 	{USB_DEVICE(0x0DF6, 0x0049)},
 	{USB_DEVICE(0x0DF6, 0x004C)},
+	{USB_DEVICE(0x0DF6, 0x006C)},
 	{USB_DEVICE(0x0DF6, 0x0064)},
 	/* Skyworth */
 	{USB_DEVICE(0x14b2, 0x3300)},
-- 
2.1.4
