From: Neal Cardwell <ncardwell@google.com>
Subject: [PATCH v2 net-next 12/16] tcp: export tcp_mss_to_mtu() for congestion control modules
Date: Sat, 17 Sep 2016 13:35:45 -0400
Message-ID: <1474133749-12895-13-git-send-email-ncardwell@google.com>
References: <1474133749-12895-1-git-send-email-ncardwell@google.com>
Cc: netdev@vger.kernel.org, Neal Cardwell <ncardwell@google.com>,
        Van Jacobson <vanj@google.com>,
        Yuchung Cheng <ycheng@google.com>,
        Nandita Dukkipati <nanditad@google.com>,
        Eric Dumazet <edumazet@google.com>,
        Soheil Hassas Yeganeh <soheil@google.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qt0-f179.google.com ([209.85.216.179]:34740 "EHLO
        mail-qt0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754295AbcIQRga (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 17 Sep 2016 13:36:30 -0400
Received: by mail-qt0-f179.google.com with SMTP id 38so56305269qte.1
        for <netdev@vger.kernel.org>; Sat, 17 Sep 2016 10:36:30 -0700 (PDT)
In-Reply-To: <1474133749-12895-1-git-send-email-ncardwell@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Export tcp_mss_to_mtu(), so that congestion control modules can use
this to help calculate a pacing rate.

Signed-off-by: Van Jacobson <vanj@google.com>
Signed-off-by: Neal Cardwell <ncardwell@google.com>
Signed-off-by: Yuchung Cheng <ycheng@google.com>
Signed-off-by: Nandita Dukkipati <nanditad@google.com>
Signed-off-by: Eric Dumazet <edumazet@google.com>
Signed-off-by: Soheil Hassas Yeganeh <soheil@google.com>
---
 net/ipv4/tcp_output.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
index 0bf3d48..7d025a7 100644
--- a/net/ipv4/tcp_output.c
+++ b/net/ipv4/tcp_output.c
@@ -1362,6 +1362,7 @@ int tcp_mss_to_mtu(struct sock *sk, int mss)
 	}
 	return mtu;
 }
+EXPORT_SYMBOL(tcp_mss_to_mtu);
 
 /* MTU probing init per socket */
 void tcp_mtup_init(struct sock *sk)
-- 
2.8.0.rc3.226.g39d4020
