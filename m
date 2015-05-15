From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next] flow_dissector: remove bogus return in tipc section
Date: Fri, 15 May 2015 13:27:32 +0200
Message-ID: <1431689252-6830-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, dan.carpenter@oracle.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f46.google.com ([74.125.82.46]:33376 "EHLO
	mail-wg0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754333AbbEOL1g (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 15 May 2015 07:27:36 -0400
Received: by wgin8 with SMTP id n8so109557168wgi.0
        for <netdev@vger.kernel.org>; Fri, 15 May 2015 04:27:35 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fixes: 06635a35d13d42b9 ("flow_dissect: use programable dissector in skb_flow_dissect and friends")
Reported-by: Dan Carpenter <dan.carpenter@oracle.com>
Signed-off-by: Jiri Pirko <jiri@resnulli.us>
---
 net/core/flow_dissector.c | 1 -
 1 file changed, 1 deletion(-)

diff --git a/net/core/flow_dissector.c b/net/core/flow_dissector.c
index 204d09c..703d059 100644
--- a/net/core/flow_dissector.c
+++ b/net/core/flow_dissector.c
@@ -279,7 +279,6 @@ flow_label:
 
 		if (skb_flow_dissector_uses_key(flow_dissector,
 						FLOW_DISSECTOR_KEY_IPV6_HASH_ADDRS)) {
-			return true;
 			key_addrs = skb_flow_dissector_target(flow_dissector,
 							      FLOW_DISSECTOR_KEY_IPV6_HASH_ADDRS,
 							      target_container);
-- 
1.9.3
