From: Enrico Mioso <mrkiko.rs@gmail.com>
Subject: [RFC PATCH 2/6] cdc_ncm: be more precise in comments for cdc_ncm_prepare_skb_ncm16
Date: Mon, 29 Dec 2014 11:09:44 +0100
Message-ID: <1419847788-25610-3-git-send-email-mrkiko.rs@gmail.com>
References: <1419847788-25610-1-git-send-email-mrkiko.rs@gmail.com>
Cc: Enrico Mioso <mrkiko.rs@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f52.google.com ([74.125.82.52]:46208 "EHLO
	mail-wg0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751991AbaL2KJx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 29 Dec 2014 05:09:53 -0500
Received: by mail-wg0-f52.google.com with SMTP id x12so18478319wgg.11
        for <netdev@vger.kernel.org>; Mon, 29 Dec 2014 02:09:52 -0800 (PST)
In-Reply-To: <1419847788-25610-1-git-send-email-mrkiko.rs@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The function might return NULL: callers must be prepared to this possibility.

Signed-Off-By: Enrico Mioso <mrkiko.rs@gmail.com>
---
 drivers/net/usb/cdc_ncm.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/usb/cdc_ncm.c b/drivers/net/usb/cdc_ncm.c
index 48fee7a..bcd9437 100644
--- a/drivers/net/usb/cdc_ncm.c
+++ b/drivers/net/usb/cdc_ncm.c
@@ -1015,7 +1015,7 @@ static struct usb_cdc_ncm_ndp16 *cdc_ncm_ndp16(struct cdc_ncm_ctx *ctx, struct s
 }
 
 /* Allocate new SKB for use with 16-bit NCM according to actual TX/RX
-	settings */
+	settings; returns NULL in case of errors */
 struct sk_buff *
 cdc_ncm_prepare_skb_ncm16(struct sk_buff *skb, struct cdc_ncm_ctx *ctx)
 {
-- 
2.2.1
