From: Enrico Mioso <mrkiko.rs@gmail.com>
Subject: [RFC PATCH 5/6] cdc_ncm: fix typo
Date: Mon, 29 Dec 2014 11:09:47 +0100
Message-ID: <1419847788-25610-6-git-send-email-mrkiko.rs@gmail.com>
References: <1419847788-25610-1-git-send-email-mrkiko.rs@gmail.com>
Cc: Enrico Mioso <mrkiko.rs@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f54.google.com ([74.125.82.54]:57584 "EHLO
	mail-wg0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752056AbaL2KJ6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 29 Dec 2014 05:09:58 -0500
Received: by mail-wg0-f54.google.com with SMTP id z12so696541wgg.13
        for <netdev@vger.kernel.org>; Mon, 29 Dec 2014 02:09:57 -0800 (PST)
In-Reply-To: <1419847788-25610-1-git-send-email-mrkiko.rs@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

It probably was "within".

Signed-Off-By: Enrico Mioso <mrkiko.rs@gmail.com>
---
 drivers/net/usb/cdc_ncm.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/usb/cdc_ncm.c b/drivers/net/usb/cdc_ncm.c
index 0970991..babfaee 100644
--- a/drivers/net/usb/cdc_ncm.c
+++ b/drivers/net/usb/cdc_ncm.c
@@ -1123,7 +1123,7 @@ cdc_ncm_fill_tx_frame(struct usbnet *dev, struct sk_buff *skb, __le32 sign)
 			break;
 		}
 
-		/* calculate frame number withing this NDP */
+		/* calculate frame number within this NDP */
 		ndplen = le16_to_cpu(ndp16->wLength);
 		index = (ndplen - sizeof(struct usb_cdc_ncm_ndp16)) / sizeof(struct usb_cdc_ncm_dpe16) - 1;
 
-- 
2.2.1
