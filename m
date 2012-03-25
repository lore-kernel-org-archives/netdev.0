From: Andrew Bird <ajb@spheresystems.co.uk>
Subject: [PATCH 3/3] USB: qmi_wwan: Add ZTE (Vodafone) K3570-Z and K3571-Z net interfaces
Date: Sun, 25 Mar 2012 11:10:29 +0100
Message-ID: <1332670229-2045-4-git-send-email-ajb@spheresystems.co.uk>
References: <1332670229-2045-1-git-send-email-ajb@spheresystems.co.uk>
Cc: smurf@smurf.noris.de, linux-usb@vger.kernel.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Andrew Bird <ajb@spheresystems.co.uk>
To: gregkh@linuxfoundation.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1332670229-2045-1-git-send-email-ajb@spheresystems.co.uk>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Now that we have the beginnings of an OSS method to use the network
interfaces on these USB broadband modems, add the ZTE manufactured
Vodafone items to the whitelist

Signed-off-by: Andrew Bird <ajb@spheresystems.co.uk>
---
 drivers/net/usb/qmi_wwan.c |   18 ++++++++++++++++++
 1 files changed, 18 insertions(+), 0 deletions(-)

diff --git a/drivers/net/usb/qmi_wwan.c b/drivers/net/usb/qmi_wwan.c
index 0f83899..552d24b 100644
--- a/drivers/net/usb/qmi_wwan.c
+++ b/drivers/net/usb/qmi_wwan.c
@@ -418,6 +418,24 @@ static const struct usb_device_id products[] = {
 		.bInterfaceProtocol = 0xff,
 		.driver_info        = (unsigned long)&qmi_wwan_force_int4,
 	},
+	{	/* ZTE (Vodafone) K3570-Z */
+		.match_flags	    = USB_DEVICE_ID_MATCH_DEVICE | USB_DEVICE_ID_MATCH_INT_INFO,
+		.idVendor           = 0x19d2,
+		.idProduct          = 0x1008,
+		.bInterfaceClass    = 0xff,
+		.bInterfaceSubClass = 0xff,
+		.bInterfaceProtocol = 0xff,
+		.driver_info        = (unsigned long)&qmi_wwan_force_int4,
+	},
+	{	/* ZTE (Vodafone) K3571-Z */
+		.match_flags	    = USB_DEVICE_ID_MATCH_DEVICE | USB_DEVICE_ID_MATCH_INT_INFO,
+		.idVendor           = 0x19d2,
+		.idProduct          = 0x1010,
+		.bInterfaceClass    = 0xff,
+		.bInterfaceSubClass = 0xff,
+		.bInterfaceProtocol = 0xff,
+		.driver_info        = (unsigned long)&qmi_wwan_force_int4,
+	},
 	{	/* ZTE (Vodafone) K4505-Z */
 		.match_flags	    = USB_DEVICE_ID_MATCH_DEVICE | USB_DEVICE_ID_MATCH_INT_INFO,
 		.idVendor           = 0x19d2,
-- 
1.7.6.5
