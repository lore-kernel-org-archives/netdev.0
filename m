From: Eric Dumazet <edumazet@google.com>
Subject: [PATCH net-next 10/15] tcp: remove stale sysctl_tcp_reordering
Date: Thu, 26 Oct 2017 16:35:21 -0700
Message-ID: <20171026233526.6155-11-edumazet@google.com>
References: <20171026233526.6155-1-edumazet@google.com>
Cc: netdev <netdev@vger.kernel.org>,
        Eric Dumazet <edumazet@google.com>,
        Eric Dumazet <eric.dumazet@gmail.com>
To: "David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f68.google.com ([74.125.83.68]:51037 "EHLO
        mail-pg0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932466AbdJZXf5 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 26 Oct 2017 19:35:57 -0400
Received: by mail-pg0-f68.google.com with SMTP id y5so3887002pgq.7
        for <netdev@vger.kernel.org>; Thu, 26 Oct 2017 16:35:56 -0700 (PDT)
In-Reply-To: <20171026233526.6155-1-edumazet@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This extern is no longer used.

Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 include/net/tcp.h | 1 -
 1 file changed, 1 deletion(-)

diff --git a/include/net/tcp.h b/include/net/tcp.h
index 38504d5ab109454219ac9570c3b11e02733384c1..c912d63839e7cd4b6ad009344e8017de4c0b1483 100644
--- a/include/net/tcp.h
+++ b/include/net/tcp.h
@@ -241,7 +241,6 @@ void tcp_time_wait(struct sock *sk, int state, int timeo);
 
 /* sysctl variables for tcp */
 extern int sysctl_tcp_max_orphans;
-extern int sysctl_tcp_reordering;
 extern int sysctl_tcp_max_reordering;
 extern int sysctl_tcp_dsack;
 extern long sysctl_tcp_mem[3];
-- 
2.15.0.rc2.357.g7e34df9404-goog
