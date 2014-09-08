From: Bojan Prtvar <prtvar.b@gmail.com>
Subject: [PATCH] netfilter: xtables:  Remove unnecessary initialization of struct ts_state
Date: Mon,  8 Sep 2014 09:51:12 +0200
Message-ID: <1410162672-5040-1-git-send-email-prtvar.b@gmail.com>
Cc: netfilter-devel@vger.kernel.org, coreteam@netfilter.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: pablo@netfilter.org, kaber@trash.net, kadlec@blackhole.kfki.hu,
	davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f177.google.com ([74.125.82.177]:56299 "EHLO
	mail-we0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752941AbaIHHvX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Sep 2014 03:51:23 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The skb_find_text() accepts uninitialized textsearch state variable.

Signed-off-by: Bojan Prtvar <prtvar.b@gmail.com>
---
 net/netfilter/xt_string.c | 1 -
 1 file changed, 1 deletion(-)

diff --git a/net/netfilter/xt_string.c b/net/netfilter/xt_string.c
index d3c48b1..5699adb 100644
--- a/net/netfilter/xt_string.c
+++ b/net/netfilter/xt_string.c
@@ -29,7 +29,6 @@ string_mt(const struct sk_buff *skb, struct xt_action_param *par)
 	struct ts_state state;
 	bool invert;
 
-	memset(&state, 0, sizeof(struct ts_state));
 	invert = conf->u.v1.flags & XT_STRING_FLAG_INVERT;
 
 	return (skb_find_text((struct sk_buff *)skb, conf->from_offset,
-- 
1.9.1.286.g5172cb3
