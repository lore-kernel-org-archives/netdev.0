From: Alexey Khoroshilov <khoroshilov@ispras.ru>
Subject: [PATCH 1/2] rsi: GFP_ATOMIC is not needed in rsi_init_usb_interface()
Date: Fri, 27 Jun 2014 02:51:24 +0400
Message-ID: <1403823085-10464-1-git-send-email-khoroshilov@ispras.ru>
Cc: Alexey Khoroshilov <khoroshilov@ispras.ru>,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, ldv-project@linuxtesting.org
To: "John W. Linville" <linville@tuxdriver.com>,
	Fariya Fatima <fariyaf@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Alexey Khoroshilov <khoroshilov@ispras.ru>
---
 drivers/net/wireless/rsi/rsi_91x_usb.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/wireless/rsi/rsi_91x_usb.c b/drivers/net/wireless/rsi/rsi_91x_usb.c
index 4c46e5631e2f..2e0254606e3d 100644
--- a/drivers/net/wireless/rsi/rsi_91x_usb.c
+++ b/drivers/net/wireless/rsi/rsi_91x_usb.c
@@ -397,7 +397,7 @@ static int rsi_init_usb_interface(struct rsi_hw *adapter,
 		return -ENOMEM;
 	}
 
-	rsi_dev->tx_buffer = kmalloc(2048, GFP_ATOMIC);
+	rsi_dev->tx_buffer = kmalloc(2048, GFP_KERNEL);
 	rsi_dev->rx_usb_urb[0] = usb_alloc_urb(0, GFP_KERNEL);
 	rsi_dev->rx_usb_urb[0]->transfer_buffer = adapter->priv->rx_data_pkt;
 	rsi_dev->tx_blk_size = 252;
-- 
1.9.1
