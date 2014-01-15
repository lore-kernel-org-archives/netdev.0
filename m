From: Tom Herbert <therbert@google.com>
Subject: [PATCH net-next v3 1/2] net: Add skb_get_hash_raw
Date: Wed, 15 Jan 2014 08:57:54 -0800 (PST)
Message-ID: <alpine.DEB.2.02.1401150853090.14881@tomh.mtv.corp.google.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f201.google.com ([209.85.214.201]:48870 "EHLO
	mail-ob0-f201.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751642AbaAOQ5z (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Jan 2014 11:57:55 -0500
Received: by mail-ob0-f201.google.com with SMTP id va2so279132obc.4
        for <netdev@vger.kernel.org>; Wed, 15 Jan 2014 08:57:55 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Function to just return skb->rxhash without checking to see if it needs
to be recomputed.

Signed-off-by: Tom Herbert <therbert@google.com>
---
 include/linux/skbuff.h | 5 +++++
 1 file changed, 5 insertions(+)

diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index 48b7605..1f689e6 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -771,6 +771,11 @@ static inline __u32 skb_get_hash(struct sk_buff *skb)
 	return skb->rxhash;
 }
 
+static inline __u32 skb_get_hash_raw(const struct sk_buff *skb)
+{
+	return skb->rxhash;
+}
+
 static inline void skb_clear_hash(struct sk_buff *skb)
 {
 	skb->rxhash = 0;
-- 
1.8.5.2
