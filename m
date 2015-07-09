From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next] tcp: do not export tcp_init_xmit_timers()
Date: Thu, 09 Jul 2015 18:01:40 +0200
Message-ID: <1436457700.24939.36.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	Neal Cardwell <ncardwell@google.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f177.google.com ([209.85.212.177]:38412 "EHLO
	mail-wi0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753398AbbGIQBp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 Jul 2015 12:01:45 -0400
Received: by wicmv11 with SMTP id mv11so5021904wic.1
        for <netdev@vger.kernel.org>; Thu, 09 Jul 2015 09:01:44 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

After commit 900f65d361d3 ("tcp: move duplicate code from
tcp_v4_init_sock()/tcp_v6_init_sock()"), we no longer
need to export tcp_init_xmit_timers()

Signed-off-by: Eric Dumazet <edumazet@google.com>
Cc: Neal Cardwell <ncardwell@google.com>
---
 net/ipv4/tcp_timer.c |    1 -
 1 file changed, 1 deletion(-)

diff --git a/net/ipv4/tcp_timer.c b/net/ipv4/tcp_timer.c
index 5b752f58a900..7149ebc820c7 100644
--- a/net/ipv4/tcp_timer.c
+++ b/net/ipv4/tcp_timer.c
@@ -649,4 +649,3 @@ void tcp_init_xmit_timers(struct sock *sk)
 	inet_csk_init_xmit_timers(sk, &tcp_write_timer, &tcp_delack_timer,
 				  &tcp_keepalive_timer);
 }
-EXPORT_SYMBOL(tcp_init_xmit_timers);
