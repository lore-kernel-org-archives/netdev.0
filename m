From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next v4 RFC 04/15] flow_dissector: fix doc for __skb_get_hash and remove couple of empty lines
Date: Fri, 24 Apr 2015 17:51:30 +0200
Message-ID: <1429890701-30052-5-git-send-email-jiri@resnulli.us>
References: <1429890701-30052-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, jhs@mojatatu.com, tgraf@suug.ch,
	jesse@nicira.com, kaber@trash.net, therbert@google.com,
	edumazet@google.com, alexander.h.duyck@redhat.com,
	hannes@stressinduktion.org, ast@plumgrid.com, daniel@iogearbox.net,
	herbert@gondor.apana.org.au, cwang@twopensource.com,
	john.fastabend@gmail.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f170.google.com ([209.85.212.170]:34081 "EHLO
	mail-wi0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1031220AbbDXPvw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 24 Apr 2015 11:51:52 -0400
Received: by wicmx19 with SMTP id mx19so38024704wic.1
        for <netdev@vger.kernel.org>; Fri, 24 Apr 2015 08:51:50 -0700 (PDT)
In-Reply-To: <1429890701-30052-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Jiri Pirko <jiri@resnulli.us>
---
 net/core/flow_dissector.c | 10 +++++-----
 1 file changed, 5 insertions(+), 5 deletions(-)

diff --git a/net/core/flow_dissector.c b/net/core/flow_dissector.c
index 1d4c54d..6a02b26 100644
--- a/net/core/flow_dissector.c
+++ b/net/core/flow_dissector.c
@@ -300,8 +300,11 @@ u32 flow_hash_from_keys(struct flow_keys *keys)
 }
 EXPORT_SYMBOL(flow_hash_from_keys);
 
-/*
- * __skb_get_hash: calculate a flow hash based on src/dst addresses
+/**
+ * __skb_get_hash - calculate a flow hash
+ * @skb: sk_buff to calculate flow hash from
+ *
+ * This function calculates a flow hash based on src/dst addresses
  * and src/dst port numbers.  Sets hash in skb to non-zero hash value
  * on success, zero indicates no valid hash.  Also, sets l4_hash in skb
  * if hash is a canonical 4-tuple hash over transport ports.
@@ -312,12 +315,9 @@ void __skb_get_hash(struct sk_buff *skb)
 
 	if (!skb_flow_dissect(skb, &keys))
 		return;
-
 	if (keys.ports)
 		skb->l4_hash = 1;
-
 	skb->sw_hash = 1;
-
 	skb->hash = __flow_hash_from_keys(&keys);
 }
 EXPORT_SYMBOL(__skb_get_hash);
-- 
1.9.3
