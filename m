From: Eric Dumazet <edumazet@google.com>
Subject: [PATCH v2 net-next 10/15] tcp: remove stale sysctl_tcp_reordering
Date: Thu, 26 Oct 2017 21:55:05 -0700
Message-ID: <20171027045510.5827-11-edumazet@google.com>
References: <20171027045510.5827-1-edumazet@google.com>
Cc: netdev <netdev@vger.kernel.org>,
        Eric Dumazet <edumazet@google.com>,
        Eric Dumazet <eric.dumazet@gmail.com>
To: "David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f195.google.com ([209.85.223.195]:46685 "EHLO
        mail-io0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751994AbdJ0Ezg (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 27 Oct 2017 00:55:36 -0400
Received: by mail-io0-f195.google.com with SMTP id 101so10132447ioj.3
        for <netdev@vger.kernel.org>; Thu, 26 Oct 2017 21:55:36 -0700 (PDT)
In-Reply-To: <20171027045510.5827-1-edumazet@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This extern is no longer used.

Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 include/net/tcp.h | 1 -
 1 file changed, 1 deletion(-)

diff --git a/include/net/tcp.h b/include/net/tcp.h
index e7b15e9f6e288908bf58a28fe24554630c1e0710..fc134ba74c7d38d08304b5be36506946784538f2 100644
--- a/include/net/tcp.h
+++ b/include/net/tcp.h
@@ -244,7 +244,6 @@ void tcp_time_wait(struct sock *sk, int state, int timeo);
 
 /* sysctl variables for tcp */
 extern int sysctl_tcp_max_orphans;
-extern int sysctl_tcp_reordering;
 extern int sysctl_tcp_max_reordering;
 extern int sysctl_tcp_dsack;
 extern long sysctl_tcp_mem[3];
-- 
2.15.0.rc2.357.g7e34df9404-goog
