From: Wei Yongjun <weiyj.lk@gmail.com>
Subject: [PATCH net-next] cdc-ether: usbnet_cdc_zte_status() can be static
Date: Thu, 12 Jan 2017 13:43:47 +0000
Message-ID: <20170112134347.22793-1-weiyj.lk@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Wei Yongjun <weiyongjun1@huawei.com>, linux-usb@vger.kernel.org,
        netdev@vger.kernel.org
To: Oliver Neukum <oliver@neukum.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f196.google.com ([209.85.192.196]:33014 "EHLO
        mail-pf0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750817AbdALNn7 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 12 Jan 2017 08:43:59 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wei Yongjun <weiyongjun1@huawei.com>

Fixes the following sparse warning:

drivers/net/usb/cdc_ether.c:469:6: warning:
 symbol 'usbnet_cdc_zte_status' was not declared. Should it be static?

Signed-off-by: Wei Yongjun <weiyongjun1@huawei.com>
---
 drivers/net/usb/cdc_ether.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/usb/cdc_ether.c b/drivers/net/usb/cdc_ether.c
index fe7b288..620ba8e 100644
--- a/drivers/net/usb/cdc_ether.c
+++ b/drivers/net/usb/cdc_ether.c
@@ -466,7 +466,7 @@ static int usbnet_cdc_zte_rx_fixup(struct usbnet *dev, struct sk_buff *skb)
  * connected. This causes the link state to be incorrect. Work around this by
  * always setting the state to off, then on.
  */
-void usbnet_cdc_zte_status(struct usbnet *dev, struct urb *urb)
+static void usbnet_cdc_zte_status(struct usbnet *dev, struct urb *urb)
 {
 	struct usb_cdc_notification *event;
