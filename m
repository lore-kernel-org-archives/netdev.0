From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 02/15] flow_dissector: remove unused function flow_get_hlen declaration
Date: Sat,  9 May 2015 15:10:25 +0200
Message-ID: <1431177038-11555-3-git-send-email-jiri@resnulli.us>
References: <1431177038-11555-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, jhs@mojatatu.com, tgraf@suug.ch,
	jesse@nicira.com, kaber@trash.net, therbert@google.com,
	edumazet@google.com, alexander.h.duyck@redhat.com,
	hannes@stressinduktion.org, ast@plumgrid.com, daniel@iogearbox.net,
	herbert@gondor.apana.org.au, cwang@twopensource.com,
	john.fastabend@gmail.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f176.google.com ([209.85.212.176]:35962 "EHLO
	mail-wi0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751396AbbEINKu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 9 May 2015 09:10:50 -0400
Received: by wizk4 with SMTP id k4so58411735wiz.1
        for <netdev@vger.kernel.org>; Sat, 09 May 2015 06:10:49 -0700 (PDT)
In-Reply-To: <1431177038-11555-1-git-send-email-jiri@resnulli.us>
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
1.9.3
