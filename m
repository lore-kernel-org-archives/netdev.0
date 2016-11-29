From: Colin King <colin.king@canonical.com>
Subject: [PATCH net-next] net: can: usb: kvaser_usb: fix spelling mistake of "outstanding"
Date: Tue, 29 Nov 2016 16:27:17 +0000
Message-ID: <20161129162717.8785-1-colin.king@canonical.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit
Cc: linux-kernel@vger.kernel.org
To: Wolfgang Grandegger <wg@grandegger.com>,
        Marc Kleine-Budde <mkl@pengutronix.de>,
        Jimmy Assarsson <jimmyassarsson@gmail.com>,
        Wolfram Sang <wsa-dev@sang-engineering.com>,
        "David S . Miller" <davem@davemloft.net>,
        linux-can@vger.kernel.org, netdev@vger.kernel.org
Return-path: <linux-can-owner@vger.kernel.org>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Colin Ian King <colin.king@canonical.com>

Trivial fix to spelling mistake "oustanding" to "outstanding" in
comment and dev_dbg message.

Signed-off-by: Colin Ian King <colin.king@canonical.com>
---
 drivers/net/can/usb/kvaser_usb.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/can/usb/kvaser_usb.c b/drivers/net/can/usb/kvaser_usb.c
index d51e0c4..18cc529 100644
--- a/drivers/net/can/usb/kvaser_usb.c
+++ b/drivers/net/can/usb/kvaser_usb.c
@@ -459,7 +459,7 @@ struct kvaser_usb {
 	struct usb_endpoint_descriptor *bulk_in, *bulk_out;
 	struct usb_anchor rx_submitted;
 
-	/* @max_tx_urbs: Firmware-reported maximum number of oustanding,
+	/* @max_tx_urbs: Firmware-reported maximum number of outstanding,
 	 * not yet ACKed, transmissions on this device. This value is
 	 * also used as a sentinel for marking free tx contexts.
 	 */
@@ -2027,7 +2027,7 @@ static int kvaser_usb_probe(struct usb_interface *intf,
 		((dev->fw_version >> 16) & 0xff),
 		(dev->fw_version & 0xffff));
 
-	dev_dbg(&intf->dev, "Max oustanding tx = %d URBs\n", dev->max_tx_urbs);
+	dev_dbg(&intf->dev, "Max outstanding tx = %d URBs\n", dev->max_tx_urbs);
 
 	err = kvaser_usb_get_card_info(dev);
 	if (err) {
-- 
2.10.2

