From: Enrico Mioso <mrkiko.rs@gmail.com>
Subject: [RFC PATCH 3/6] cdc_ncm: add needed members to cdc_ncm_ctx for refactoring
Date: Mon, 29 Dec 2014 11:09:45 +0100
Message-ID: <1419847788-25610-4-git-send-email-mrkiko.rs@gmail.com>
References: <1419847788-25610-1-git-send-email-mrkiko.rs@gmail.com>
Cc: Enrico Mioso <mrkiko.rs@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f51.google.com ([74.125.82.51]:48909 "EHLO
	mail-wg0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751995AbaL2KJy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 29 Dec 2014 05:09:54 -0500
Received: by mail-wg0-f51.google.com with SMTP id x12so18408343wgg.38
        for <netdev@vger.kernel.org>; Mon, 29 Dec 2014 02:09:53 -0800 (PST)
In-Reply-To: <1419847788-25610-1-git-send-email-mrkiko.rs@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We intend to use something like a TX queue - so prepare the driver's header
file for this.

Signed-Off-By: Enrico Mioso <mrkiko.rs@gmail.com>
---
 include/linux/usb/cdc_ncm.h | 1 +
 1 file changed, 1 insertion(+)

diff --git a/include/linux/usb/cdc_ncm.h b/include/linux/usb/cdc_ncm.h
index 7c9b484..6710555 100644
--- a/include/linux/usb/cdc_ncm.h
+++ b/include/linux/usb/cdc_ncm.h
@@ -100,6 +100,7 @@ struct cdc_ncm_ctx {
 	struct sk_buff *tx_curr_skb;
 	struct sk_buff *tx_rem_skb;
 	__le32 tx_rem_sign;
+	struct sk_buff_head tx_skb_queue;
 
 	spinlock_t mtx;
 	atomic_t stop;
-- 
2.2.1
