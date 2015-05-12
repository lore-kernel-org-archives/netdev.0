From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next v3 04/15] flow_dissector: fix doc for __skb_get_hash and remove couple of empty lines
Date: Tue, 12 May 2015 14:56:10 +0200
Message-ID: <1431435381-7164-5-git-send-email-jiri@resnulli.us>
References: <1431435381-7164-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, jhs@mojatatu.com, tgraf@suug.ch,
	jesse@nicira.com, kaber@trash.net, tom@herbertland.com,
	edumazet@google.com, alexander.h.duyck@redhat.com,
	hannes@stressinduktion.org, ast@plumgrid.com, daniel@iogearbox.net,
	herbert@gondor.apana.org.au, cwang@twopensource.com,
	john.fastabend@gmail.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f48.google.com ([74.125.82.48]:35570 "EHLO
	mail-wg0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933118AbbELM4s (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 May 2015 08:56:48 -0400
Received: by wgnd10 with SMTP id d10so6299415wgn.2
        for <netdev@vger.kernel.org>; Tue, 12 May 2015 05:56:47 -0700 (PDT)
In-Reply-To: <1431435381-7164-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Jiri Pirko <jiri@resnulli.us>
---
 net/core/flow_dissector.c | 10 +++++-----
 1 file changed, 5 insertions(+), 5 deletions(-)

diff --git a/net/core/flow_dissector.c b/net/core/flow_dissector.c
index eaa86b5..0d9bc3a 100644
--- a/net/core/flow_dissector.c
+++ b/net/core/flow_dissector.c
@@ -337,8 +337,11 @@ void make_flow_keys_digest(struct flow_keys_digest *digest,
 }
 EXPORT_SYMBOL(make_flow_keys_digest);
 
-/*
- * __skb_get_hash: calculate a flow hash based on src/dst addresses
+/**
+ * __skb_get_hash: calculate a flow hash
+ * @skb: sk_buff to calculate flow hash from
+ *
+ * This function calculates a flow hash based on src/dst addresses
  * and src/dst port numbers.  Sets hash in skb to non-zero hash value
  * on success, zero indicates no valid hash.  Also, sets l4_hash in skb
  * if hash is a canonical 4-tuple hash over transport ports.
@@ -353,12 +356,9 @@ void __skb_get_hash(struct sk_buff *skb)
 	hash = ___skb_get_hash(skb, &keys, hashrnd);
 	if (!hash)
 		return;
-
 	if (keys.ports)
 		skb->l4_hash = 1;
-
 	skb->sw_hash = 1;
-
 	skb->hash = hash;
 }
 EXPORT_SYMBOL(__skb_get_hash);
-- 
2.4.0
