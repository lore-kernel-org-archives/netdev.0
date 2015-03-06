From: Willem de Bruijn <willemb@google.com>
Subject: [PATCH net-next] fib: make netdev_switch_fib_ipv4_abort in header file static inline
Date: Fri,  6 Mar 2015 11:44:28 -0500
Message-ID: <1425660268-23344-1-git-send-email-willemb@google.com>
Cc: davem@davemloft.net, sfeldma@gmail.com, alexander.duyck@gmail.com,
	Willem de Bruijn <willemb@google.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yk0-f175.google.com ([209.85.160.175]:40508 "EHLO
	mail-yk0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750781AbbCFQon (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 Mar 2015 11:44:43 -0500
Received: by ykq142 with SMTP id 142so1507943ykq.7
        for <netdev@vger.kernel.org>; Fri, 06 Mar 2015 08:44:42 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Willem de Bruijn <willemb@google.com>

When building without CONFIG_NET_SWITCHDEV,
netdev_switch_fib_ipv4_abort is defined in the header file. It must
be static inline to avoid build failure at link time.

Fixes: 8e05fd7166c6 ("fib: hook IPv4 fib for hardware offload")

Signed-off-by: Willem de Bruijn <willemb@google.com>
---
 include/net/switchdev.h | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/include/net/switchdev.h b/include/net/switchdev.h
index dc0a5cc..933fac4 100644
--- a/include/net/switchdev.h
+++ b/include/net/switchdev.h
@@ -129,7 +129,7 @@ static inline int netdev_switch_fib_ipv4_del(u32 dst, int dst_len,
 	return 0;
 }
 
-void netdev_switch_fib_ipv4_abort(struct fib_info *fi)
+static inline void netdev_switch_fib_ipv4_abort(struct fib_info *fi)
 {
 }
 
-- 
2.2.0.rc0.207.ga3a616c
