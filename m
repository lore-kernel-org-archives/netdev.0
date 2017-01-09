From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net] net: skb_flow_get_be16() can be static
Date: Mon, 09 Jan 2017 11:18:01 -0800
Message-ID: <1483989481.21472.16.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f194.google.com ([209.85.192.194]:33871 "EHLO
        mail-pf0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752180AbdAITSD (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 9 Jan 2017 14:18:03 -0500
Received: by mail-pf0-f194.google.com with SMTP id y143so3980428pfb.1
        for <netdev@vger.kernel.org>; Mon, 09 Jan 2017 11:18:03 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

Removes following sparse complain :

net/core/flow_dissector.c:70:8: warning: symbol 'skb_flow_get_be16'
was not declared. Should it be static?

Fixes: 972d3876faa8 ("flow dissector: ICMP support")
Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 net/core/flow_dissector.c |    4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/core/flow_dissector.c b/net/core/flow_dissector.c
index fe4e1531976c3a36127b6ad4af33f24534af4c52..1b7673aac59d51a5f8b5ef3f2076f1440c017fae 100644
--- a/net/core/flow_dissector.c
+++ b/net/core/flow_dissector.c
@@ -67,8 +67,8 @@ EXPORT_SYMBOL(skb_flow_dissector_init);
  * The function will try to retrieve a be32 entity at
  * offset poff
  */
-__be16 skb_flow_get_be16(const struct sk_buff *skb, int poff, void *data,
-			 int hlen)
+static __be16 skb_flow_get_be16(const struct sk_buff *skb, int poff,
+				void *data, int hlen)
 {
 	__be16 *u, _u;
 
