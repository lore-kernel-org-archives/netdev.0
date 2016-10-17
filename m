From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net] soreuseport: do not export reuseport_add_sock()
Date: Mon, 17 Oct 2016 14:22:48 -0700
Message-ID: <1476739368.5650.60.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f66.google.com ([209.85.220.66]:36137 "EHLO
        mail-pa0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1030336AbcJQVWv (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 17 Oct 2016 17:22:51 -0400
Received: by mail-pa0-f66.google.com with SMTP id os4so5529687pac.3
        for <netdev@vger.kernel.org>; Mon, 17 Oct 2016 14:22:50 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

reuseport_add_sock() is not used from a module,
no need to export it.

Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 net/core/sock_reuseport.c |    1 -
 1 file changed, 1 deletion(-)

diff --git a/net/core/sock_reuseport.c b/net/core/sock_reuseport.c
index e92b759d906c..9a1a352fd1eb 100644
--- a/net/core/sock_reuseport.c
+++ b/net/core/sock_reuseport.c
@@ -129,7 +129,6 @@ int reuseport_add_sock(struct sock *sk, struct sock *sk2)
 
 	return 0;
 }
-EXPORT_SYMBOL(reuseport_add_sock);
 
 static void reuseport_free_rcu(struct rcu_head *head)
 {
