From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net] udp: include addrconf.h
Date: Thu, 18 Aug 2016 09:59:12 -0700
Message-ID: <1471539552.29842.69.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f193.google.com ([209.85.192.193]:36563 "EHLO
        mail-pf0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754221AbcHSCLQ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 18 Aug 2016 22:11:16 -0400
Received: by mail-pf0-f193.google.com with SMTP id y134so629552pfg.3
        for <netdev@vger.kernel.org>; Thu, 18 Aug 2016 19:11:08 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

Include ipv4_rcv_saddr_equal() definition to avoid this sparse error :

net/ipv4/udp.c:362:5: warning: symbol 'ipv4_rcv_saddr_equal' was not
declared. Should it be static?

Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 net/ipv4/udp.c |    1 +
 1 file changed, 1 insertion(+)

diff --git a/net/ipv4/udp.c b/net/ipv4/udp.c
index e61f7cd65d08..8f5f7f6026f7 100644
--- a/net/ipv4/udp.c
+++ b/net/ipv4/udp.c
@@ -114,6 +114,7 @@
 #include <net/busy_poll.h>
 #include "udp_impl.h"
 #include <net/sock_reuseport.h>
+#include <net/addrconf.h>
 
 struct udp_table udp_table __read_mostly;
 EXPORT_SYMBOL(udp_table);
