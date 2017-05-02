From: John Fastabend <john.fastabend@gmail.com>
Subject: [RFC PATCH v2 14/17] net: skb_array: expose peek API
Date: Tue, 02 May 2017 08:40:32 -0700
Message-ID: <20170502154032.9304.50203.stgit@john-Precision-Tower-5810>
References: <20170502153518.9304.17904.stgit@john-Precision-Tower-5810>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, john.fastabend@gmail.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f65.google.com ([74.125.83.65]:34425 "EHLO
        mail-pg0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750725AbdEBPkq (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 2 May 2017 11:40:46 -0400
Received: by mail-pg0-f65.google.com with SMTP id t7so23047699pgt.1
        for <netdev@vger.kernel.org>; Tue, 02 May 2017 08:40:46 -0700 (PDT)
In-Reply-To: <20170502153518.9304.17904.stgit@john-Precision-Tower-5810>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This adds a peek routine to skb_array.h for use with qdisc.

Signed-off-by: John Fastabend <john.r.fastabend@intel.com>
---
 include/linux/skb_array.h |    5 +++++
 1 file changed, 5 insertions(+)

diff --git a/include/linux/skb_array.h b/include/linux/skb_array.h
index f4dfade..33f1f0c 100644
--- a/include/linux/skb_array.h
+++ b/include/linux/skb_array.h
@@ -72,6 +72,11 @@ static inline bool __skb_array_empty(struct skb_array *a)
 	return !__ptr_ring_peek(&a->ring);
 }
 
+static inline struct sk_buff *skb_array_peek(struct skb_array *a)
+{
+	return __ptr_ring_peek(&a->ring);
+}
+
 static inline bool skb_array_empty(struct skb_array *a)
 {
 	return ptr_ring_empty(&a->ring);
