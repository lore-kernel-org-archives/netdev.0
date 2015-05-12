From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next v3 02/15] flow_dissector: remove unused function flow_get_hlen declaration
Date: Tue, 12 May 2015 14:56:08 +0200
Message-ID: <1431435381-7164-3-git-send-email-jiri@resnulli.us>
References: <1431435381-7164-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, jhs@mojatatu.com, tgraf@suug.ch,
	jesse@nicira.com, kaber@trash.net, tom@herbertland.com,
	edumazet@google.com, alexander.h.duyck@redhat.com,
	hannes@stressinduktion.org, ast@plumgrid.com, daniel@iogearbox.net,
	herbert@gondor.apana.org.au, cwang@twopensource.com,
	john.fastabend@gmail.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f50.google.com ([74.125.82.50]:33407 "EHLO
	mail-wg0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932639AbbELM4i (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 May 2015 08:56:38 -0400
Received: by wgin8 with SMTP id n8so8816881wgi.0
        for <netdev@vger.kernel.org>; Tue, 12 May 2015 05:56:37 -0700 (PDT)
In-Reply-To: <1431435381-7164-1-git-send-email-jiri@resnulli.us>
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
index 5e99a7b..118ae69 100644
--- a/include/net/flow_dissector.h
+++ b/include/net/flow_dissector.h
@@ -47,9 +47,6 @@ static inline __be32 skb_flow_get_ports(const struct sk_buff *skb,
 
 u32 flow_hash_from_keys(struct flow_keys *keys);
 
-unsigned int flow_get_hlen(const unsigned char *data, unsigned int max_len,
-			   __be16 protocol);
-
 /* struct flow_keys_digest:
  *
  * This structure is used to hold a digest of the full flow keys. This is a
-- 
2.4.0
