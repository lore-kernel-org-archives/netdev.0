From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next v4 RFC 08/15] flow_dissector: fix doc for skb_get_poff
Date: Fri, 24 Apr 2015 17:51:34 +0200
Message-ID: <1429890701-30052-9-git-send-email-jiri@resnulli.us>
References: <1429890701-30052-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, jhs@mojatatu.com, tgraf@suug.ch,
	jesse@nicira.com, kaber@trash.net, therbert@google.com,
	edumazet@google.com, alexander.h.duyck@redhat.com,
	hannes@stressinduktion.org, ast@plumgrid.com, daniel@iogearbox.net,
	herbert@gondor.apana.org.au, cwang@twopensource.com,
	john.fastabend@gmail.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f179.google.com ([209.85.212.179]:35525 "EHLO
	mail-wi0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1031216AbbDXPv6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 24 Apr 2015 11:51:58 -0400
Received: by widdi4 with SMTP id di4so27219543wid.0
        for <netdev@vger.kernel.org>; Fri, 24 Apr 2015 08:51:57 -0700 (PDT)
In-Reply-To: <1429890701-30052-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Jiri Pirko <jiri@resnulli.us>
---
 net/core/flow_dissector.c | 8 ++++++--
 1 file changed, 6 insertions(+), 2 deletions(-)

diff --git a/net/core/flow_dissector.c b/net/core/flow_dissector.c
index 9c12692..5213d73 100644
--- a/net/core/flow_dissector.c
+++ b/net/core/flow_dissector.c
@@ -368,8 +368,12 @@ u32 __skb_get_poff(const struct sk_buff *skb, void *data,
 	return poff;
 }
 
-/* skb_get_poff() returns the offset to the payload as far as it could
- * be dissected. The main user is currently BPF, so that we can dynamically
+/**
+ * skb_get_poff - get the offset to the payload
+ * @skb: sk_buff to get the payload offset from
+ *
+ * The function will get the offset to the payload as far as it could
+ * be dissected.  The main user is currently BPF, so that we can dynamically
  * truncate packets without needing to push actual payload to the user
  * space and can analyze headers only, instead.
  */
-- 
1.9.3
