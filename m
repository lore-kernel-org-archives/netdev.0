From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next] ipv6: add include file to suppress sparse warnings
Date: Tue, 25 Jun 2013 01:30:11 -0700
Message-ID: <1372149011.3301.88.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>, Cong Wang <amwang@redhat.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f47.google.com ([209.85.215.47]:42854 "EHLO
	mail-la0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751506Ab3FYIaN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Jun 2013 04:30:13 -0400
Received: by mail-la0-f47.google.com with SMTP id fe20so11453583lab.6
        for <netdev@vger.kernel.org>; Tue, 25 Jun 2013 01:30:11 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

commit f88c91ddba95 ("ipv6: statically link
register_inet6addr_notifier()" added following sparse warnings :

net/ipv6/addrconf_core.c:83:5: warning: symbol
'register_inet6addr_notifier' was not declared. Should it be static?
net/ipv6/addrconf_core.c:89:5: warning: symbol
'unregister_inet6addr_notifier' was not declared. Should it be static?
net/ipv6/addrconf_core.c:95:5: warning: symbol
'inet6addr_notifier_call_chain' was not declared. Should it be static?

Signed-off-by: Eric Dumazet <edumazet@google.com>
Cc: Cong Wang <amwang@redhat.com>
---
 net/ipv6/addrconf_core.c |    1 +
 1 file changed, 1 insertion(+)

diff --git a/net/ipv6/addrconf_core.c b/net/ipv6/addrconf_core.c
index 7210456..d2f8742 100644
--- a/net/ipv6/addrconf_core.c
+++ b/net/ipv6/addrconf_core.c
@@ -5,6 +5,7 @@
 
 #include <linux/export.h>
 #include <net/ipv6.h>
+#include <net/addrconf.h>
 
 #define IPV6_ADDR_SCOPE_TYPE(scope)	((scope) << 16)
 
