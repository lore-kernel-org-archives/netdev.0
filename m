From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next v4 RFC 02/15] flow_dissector: remove unused function flow_get_hlen declaration
Date: Fri, 24 Apr 2015 17:51:28 +0200
Message-ID: <1429890701-30052-3-git-send-email-jiri@resnulli.us>
References: <1429890701-30052-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, jhs@mojatatu.com, tgraf@suug.ch,
	jesse@nicira.com, kaber@trash.net, therbert@google.com,
	edumazet@google.com, alexander.h.duyck@redhat.com,
	hannes@stressinduktion.org, ast@plumgrid.com, daniel@iogearbox.net,
	herbert@gondor.apana.org.au, cwang@twopensource.com,
	john.fastabend@gmail.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f181.google.com ([209.85.212.181]:37439 "EHLO
	mail-wi0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1031079AbbDXPvt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 24 Apr 2015 11:51:49 -0400
Received: by widdi4 with SMTP id di4so25122820wid.0
        for <netdev@vger.kernel.org>; Fri, 24 Apr 2015 08:51:47 -0700 (PDT)
In-Reply-To: <1429890701-30052-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

commit 56193d1bce ("net: Add function for parsing the header length out
of linear ethernet frames") added this function declaration but it is
defined nowhere.

Signed-off-by: Jiri Pirko <jiri@resnulli.us>
---
 include/net/flow_dissector.h | 3 ---
 1 file changed, 3 deletions(-)

diff --git a/include/net/flow_dissector.h b/include/net/flow_dissector.h
index f01a54e..40ca75c 100644
--- a/include/net/flow_dissector.h
+++ b/include/net/flow_dissector.h
@@ -47,7 +47,4 @@ static inline __be32 skb_flow_get_ports(const struct sk_buff *skb,
 
 u32 flow_hash_from_keys(struct flow_keys *keys);
 
-unsigned int flow_get_hlen(const unsigned char *data, unsigned int max_len,
-			   __be16 protocol);
-
 #endif
-- 
1.9.3
