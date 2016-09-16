From: Neal Cardwell <ncardwell@google.com>
Subject: [PATCH net-next 10/14] tcp: export tcp_mss_to_mtu() for congestion control modules
Date: Fri, 16 Sep 2016 14:48:59 -0400
Message-ID: <1474051743-13311-11-git-send-email-ncardwell@google.com>
References: <1474051743-13311-1-git-send-email-ncardwell@google.com>
Cc: netdev@vger.kernel.org, Neal Cardwell <ncardwell@google.com>,
        Van Jacobson <vanj@google.com>,
        Yuchung Cheng <ycheng@google.com>,
        Nandita Dukkipati <nanditad@google.com>,
        Eric Dumazet <edumazet@google.com>,
        Soheil Hassas Yeganeh <soheil@google.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f177.google.com ([209.85.220.177]:35395 "EHLO
        mail-qk0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S933606AbcIPSuD (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 16 Sep 2016 14:50:03 -0400
Received: by mail-qk0-f177.google.com with SMTP id t7so97132767qkh.2
        for <netdev@vger.kernel.org>; Fri, 16 Sep 2016 11:50:03 -0700 (PDT)
In-Reply-To: <1474051743-13311-1-git-send-email-ncardwell@google.com>
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
