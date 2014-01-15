From: Tom Herbert <therbert@google.com>
Subject: [PATCH net-next v2 1/2] net: Add skb_get_hash_noeval
Date: Tue, 14 Jan 2014 16:01:58 -0800 (PST)
Message-ID: <alpine.DEB.2.02.1401141556350.25158@tomh.mtv.corp.google.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ve0-f201.google.com ([209.85.128.201]:35809 "EHLO
	mail-ve0-f201.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751610AbaAOACA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Jan 2014 19:02:00 -0500
Received: by mail-ve0-f201.google.com with SMTP id jw12so43285veb.4
        for <netdev@vger.kernel.org>; Tue, 14 Jan 2014 16:01:59 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Function to just return skb->rxhash without checking to see if it needs
to be recomputed.

Signed-off-by: Tom Herbert <therbert@google.com>
---
 include/linux/skbuff.h | 5 +++++
 1 file changed, 5 insertions(+)

diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index d97f2d0..bbdc847 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -771,6 +771,11 @@ static inline __u32 skb_get_hash(struct sk_buff *skb)
 	return skb->rxhash;
 }
 
+static inline __u32 skb_get_hash_noeval(struct sk_buff *skb)
+{
+	return skb->rxhash;
+}
+
 static inline void skb_clear_hash(struct sk_buff *skb)
 {
 	skb->rxhash = 0;
-- 
1.8.5.2
