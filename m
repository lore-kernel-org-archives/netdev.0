From: Stephen Hemminger <stephen@networkplumber.org>
Subject: [PATCH net-next 4/9] inet: fix warning about missing prototype
Date: Fri, 19 May 2017 09:55:51 -0700
Message-ID: <20170519165556.483-5-sthemmin@microsoft.com>
References: <20170519165556.483-1-sthemmin@microsoft.com>
Cc: netdev@vger.kernel.org, Stephen Hemminger <sthemmin@microsoft.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f169.google.com ([209.85.192.169]:33779 "EHLO
        mail-pf0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753589AbdESQ4I (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 19 May 2017 12:56:08 -0400
Received: by mail-pf0-f169.google.com with SMTP id e193so42532759pfh.0
        for <netdev@vger.kernel.org>; Fri, 19 May 2017 09:56:08 -0700 (PDT)
In-Reply-To: <20170519165556.483-1-sthemmin@microsoft.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The prototype for inet_rcv_saddr_equal was not being included.

Signed-off-by: Stephen Hemminger <sthemmin@microsoft.com>
---
 net/ipv4/inet_connection_sock.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/net/ipv4/inet_connection_sock.c b/net/ipv4/inet_connection_sock.c
index 1054d330bf9d..82dec8825d28 100644
--- a/net/ipv4/inet_connection_sock.c
+++ b/net/ipv4/inet_connection_sock.c
@@ -25,6 +25,7 @@
 #include <net/xfrm.h>
 #include <net/tcp.h>
 #include <net/sock_reuseport.h>
+#include <net/addrconf.h>
 
 #ifdef INET_CSK_DEBUG
 const char inet_csk_timer_bug_msg[] = "inet_csk BUG: unknown timer value\n";
-- 
2.11.0
