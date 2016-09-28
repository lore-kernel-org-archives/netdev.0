From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next] net: do not export sk_stream_write_space
Date: Wed, 28 Sep 2016 08:41:16 -0700
Message-ID: <1475077276.28155.108.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
        Neal Cardwell <ncardwell@google.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f65.google.com ([209.85.220.65]:35006 "EHLO
        mail-pa0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932691AbcI1PlS (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 28 Sep 2016 11:41:18 -0400
Received: by mail-pa0-f65.google.com with SMTP id j3so2212582paj.2
        for <netdev@vger.kernel.org>; Wed, 28 Sep 2016 08:41:18 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

Since commit 900f65d361d3 ("tcp: move duplicate code from
tcp_v4_init_sock()/tcp_v6_init_sock()") we no longer need
to export sk_stream_write_space()

From: Eric Dumazet <edumazet@google.com>
Cc: Neal Cardwell <ncardwell@google.com>
---
 net/core/stream.c |    1 -
 1 file changed, 1 deletion(-)

diff --git a/net/core/stream.c b/net/core/stream.c
index 159516a11b7e84f7e64e0acfa2dd55dab82307bd..1086c8b280a868101df7b44691eccac40bd7b3e1 100644
--- a/net/core/stream.c
+++ b/net/core/stream.c
@@ -43,7 +43,6 @@ void sk_stream_write_space(struct sock *sk)
 		rcu_read_unlock();
 	}
 }
-EXPORT_SYMBOL(sk_stream_write_space);
 
 /**
  * sk_stream_wait_connect - Wait for a socket to get into the connected state
