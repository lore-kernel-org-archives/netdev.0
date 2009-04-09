From: Wei Yongjun <yjwei@cn.fujitsu.com>
Subject: at76c50x-usb: remove pointless conditional before kfree_skb()
Date: Thu, 09 Apr 2009 16:16:38 +0800
Message-ID: <49DDAEE6.6020603@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=GB2312
Content-Transfer-Encoding: 7bit
To: "John W. Linville" <linville@tuxdriver.com>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:59770 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1751911AbZDIISD (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 9 Apr 2009 04:18:03 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Remove pointless conditional before kfree_skb().

Signed-off-by: Wei Yongjun <yjwei@cn.fujitsu.com>
---
 drivers/net/wireless/at76c50x-usb.c |    3 +--
 1 files changed, 1 insertions(+), 2 deletions(-)

diff --git a/drivers/net/wireless/at76c50x-usb.c b/drivers/net/wireless/at76c50x-usb.c
index 0c02f1c..c220c97 100644
--- a/drivers/net/wireless/at76c50x-usb.c
+++ b/drivers/net/wireless/at76c50x-usb.c
@@ -2309,8 +2309,7 @@ static void at76_delete_device(struct at76_priv *priv)
 
 	del_timer_sync(&ledtrig_tx_timer);
 
-	if (priv->rx_skb)
-		kfree_skb(priv->rx_skb);
+	kfree_skb(priv->rx_skb);
 
 	usb_put_dev(priv->udev);
 
-- 
1.5.3.8




