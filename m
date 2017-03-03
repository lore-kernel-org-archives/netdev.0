From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: [PATCH 2/4] can: gs_usb: fix coding style
Date: Fri,  3 Mar 2017 14:55:33 +0100
Message-ID: <20170303135535.22937-3-mkl@pengutronix.de>
References: <20170303135535.22937-1-mkl@pengutronix.de>
Cc: davem@davemloft.net, linux-can@vger.kernel.org,
        kernel@pengutronix.de, Ethan Zonca <e@ethanzonca.com>,
        Marc Kleine-Budde <mkl@pengutronix.de>
To: netdev@vger.kernel.org
Return-path: <linux-can-owner@vger.kernel.org>
In-Reply-To: <20170303135535.22937-1-mkl@pengutronix.de>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Ethan Zonca <e@ethanzonca.com>

This patch fixes five minor style issues, spaces are between bitwise OR
operators.

Signed-off-by: Ethan Zonca <e@ethanzonca.com>
Signed-off-by: Marc Kleine-Budde <mkl@pengutronix.de>
---
 drivers/net/can/usb/gs_usb.c | 11 +++++------
 1 file changed, 5 insertions(+), 6 deletions(-)

diff --git a/drivers/net/can/usb/gs_usb.c b/drivers/net/can/usb/gs_usb.c
index a0dabd4038ba..300349fe8dc0 100644
--- a/drivers/net/can/usb/gs_usb.c
+++ b/drivers/net/can/usb/gs_usb.c
@@ -258,7 +258,7 @@ static int gs_cmd_reset(struct gs_usb *gsusb, struct gs_can *gsdev)
 	rc = usb_control_msg(interface_to_usbdev(intf),
 			     usb_sndctrlpipe(interface_to_usbdev(intf), 0),
 			     GS_USB_BREQ_MODE,
-			     USB_DIR_OUT|USB_TYPE_VENDOR|USB_RECIP_INTERFACE,
+			     USB_DIR_OUT | USB_TYPE_VENDOR | USB_RECIP_INTERFACE,
 			     gsdev->channel,
 			     0,
 			     dm,
@@ -432,7 +432,7 @@ static int gs_usb_set_bittiming(struct net_device *netdev)
 	rc = usb_control_msg(interface_to_usbdev(intf),
 			     usb_sndctrlpipe(interface_to_usbdev(intf), 0),
 			     GS_USB_BREQ_BITTIMING,
-			     USB_DIR_OUT|USB_TYPE_VENDOR|USB_RECIP_INTERFACE,
+			     USB_DIR_OUT | USB_TYPE_VENDOR | USB_RECIP_INTERFACE,
 			     dev->channel,
 			     0,
 			     dbt,
@@ -546,7 +546,6 @@ static netdev_tx_t gs_can_start_xmit(struct sk_buff *skb,
 				  hf,
 				  urb->transfer_dma);
 
-
 		if (rc == -ENODEV) {
 			netif_device_detach(netdev);
 		} else {
@@ -804,7 +803,7 @@ static struct gs_can *gs_make_candev(unsigned int channel,
 	rc = usb_control_msg(interface_to_usbdev(intf),
 			     usb_rcvctrlpipe(interface_to_usbdev(intf), 0),
 			     GS_USB_BREQ_BT_CONST,
-			     USB_DIR_IN|USB_TYPE_VENDOR|USB_RECIP_INTERFACE,
+			     USB_DIR_IN | USB_TYPE_VENDOR | USB_RECIP_INTERFACE,
 			     channel,
 			     0,
 			     bt_const,
@@ -921,7 +920,7 @@ static int gs_usb_probe(struct usb_interface *intf,
 	rc = usb_control_msg(interface_to_usbdev(intf),
 			     usb_sndctrlpipe(interface_to_usbdev(intf), 0),
 			     GS_USB_BREQ_HOST_FORMAT,
-			     USB_DIR_OUT|USB_TYPE_VENDOR|USB_RECIP_INTERFACE,
+			     USB_DIR_OUT | USB_TYPE_VENDOR | USB_RECIP_INTERFACE,
 			     1,
 			     intf->altsetting[0].desc.bInterfaceNumber,
 			     hconf,
@@ -944,7 +943,7 @@ static int gs_usb_probe(struct usb_interface *intf,
 	rc = usb_control_msg(interface_to_usbdev(intf),
 			     usb_rcvctrlpipe(interface_to_usbdev(intf), 0),
 			     GS_USB_BREQ_DEVICE_CONFIG,
-			     USB_DIR_IN|USB_TYPE_VENDOR|USB_RECIP_INTERFACE,
+			     USB_DIR_IN | USB_TYPE_VENDOR | USB_RECIP_INTERFACE,
 			     1,
 			     intf->altsetting[0].desc.bInterfaceNumber,
 			     dconf,
-- 
2.11.0

