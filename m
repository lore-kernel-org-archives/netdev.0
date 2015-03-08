From: weizhewang <hmsjwzb56@gmail.com>
Subject: [PATCH]  Drivers: net: ieee802154: mrf24j40: fix some space around operator coding style issues
Date: Sun,  8 Mar 2015 11:34:01 +0800
Message-ID: <1425785641-10056-1-git-send-email-weizhewang@yahoo.com>
Cc: alex.aring@gmail.com, linux-wpan@vger.kernel.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	weizhewang <weizhewang@yahoo.com>
To: alan@signal11.us
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

 Fixed some codeing style issues.

 Signed-off-by: hmsjwzb<hmsjwzb56@gmail.com>
---
 drivers/net/ieee802154/mrf24j40.c | 18 +++++++++---------
 1 file changed, 9 insertions(+), 9 deletions(-)

diff --git a/drivers/net/ieee802154/mrf24j40.c b/drivers/net/ieee802154/mrf24j40.c
index fba2dfd..d35c7a0 100644
--- a/drivers/net/ieee802154/mrf24j40.c
+++ b/drivers/net/ieee802154/mrf24j40.c
@@ -235,9 +235,9 @@ static int write_tx_buf(struct mrf24j40 *devrec, u16 reg,
 	};
 
 	/* Range check the length. 2 bytes are used for the length fields.*/
-	if (length > TX_FIFO_SIZE-2) {
+	if (length > TX_FIFO_SIZE - 2) {
 		dev_err(printdev(devrec), "write_tx_buf() was passed too large a buffer. Performing short write.\n");
-		length = TX_FIFO_SIZE-2;
+		length = TX_FIFO_SIZE - 2;
 	}
 
 	spi_message_init(&msg);
@@ -290,9 +290,9 @@ static int mrf24j40_read_rx_buf(struct mrf24j40 *devrec,
 
 	/* Range check the RX FIFO length, accounting for the one-byte
 	 * length field at the beginning. */
-	if (rx_len > RX_FIFO_SIZE-1) {
+	if (rx_len > RX_FIFO_SIZE - 1) {
 		dev_err(printdev(devrec), "Invalid length read from device. Performing short read.\n");
-		rx_len = RX_FIFO_SIZE-1;
+		rx_len = RX_FIFO_SIZE - 1;
 	}
 
 	if (rx_len > *len) {
@@ -302,7 +302,7 @@ static int mrf24j40_read_rx_buf(struct mrf24j40 *devrec,
 	}
 
 	/* Set up the commands to read the data. */
-	cmd = MRF24J40_READLONG(REG_RX_FIFO+1);
+	cmd = MRF24J40_READLONG(REG_RX_FIFO + 1);
 	addr[0] = cmd >> 8 & 0xff;
 	addr[1] = cmd & 0xff;
 	data_xfer.len = rx_len;
@@ -402,7 +402,7 @@ static int mrf24j40_start(struct ieee802154_hw *hw)
 	ret = read_short_reg(devrec, REG_INTCON, &val);
 	if (ret)
 		return ret;
-	val &= ~(0x1|0x8); /* Clear TXNIE and RXIE. Enable interrupts */
+	val &= ~(0x1 | 0x8); /* Clear TXNIE and RXIE. Enable interrupts */
 	write_short_reg(devrec, REG_INTCON, val);
 
 	return 0;
@@ -419,7 +419,7 @@ static void mrf24j40_stop(struct ieee802154_hw *hw)
 	ret = read_short_reg(devrec, REG_INTCON, &val);
 	if (ret)
 		return;
-	val |= 0x1|0x8; /* Set TXNIE and RXIE. Disable Interrupts */
+	val |= 0x1 | 0x8; /* Set TXNIE and RXIE. Disable Interrupts */
 	write_short_reg(devrec, REG_INTCON, val);
 }
 
@@ -436,7 +436,7 @@ static int mrf24j40_set_channel(struct ieee802154_hw *hw, u8 page, u8 channel)
 	WARN_ON(channel > MRF24J40_CHAN_MAX);
 
 	/* Set Channel TODO */
-	val = (channel-11) << 4 | 0x03;
+	val = (channel - 11) << 4 | 0x03;
 	write_long_reg(devrec, REG_RFCON0, val);
 
 	/* RF Reset */
@@ -558,7 +558,7 @@ static int mrf24j40_handle_rx(struct mrf24j40 *devrec)
 	}
 
 	/* Cut off the checksum */
-	skb_trim(skb, len-2);
+	skb_trim(skb, len - 2);
 
 	/* TODO: Other drivers call ieee20154_rx_irqsafe() here (eg: cc2040,
 	 * also from a workqueue).  I think irqsafe is not necessary here.
-- 
1.9.1
