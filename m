From: akpm@linux-foundation.org
Subject: [patch 06/28] Clean up duplicate includes in net/ipv6/
Date: Fri, 10 Aug 2007 14:11:52 -0700
Message-ID: <200708102111.l7ALBq4E009388@imap1.linux-foundation.org>
Cc: netdev@vger.kernel.org, akpm@linux-foundation.org,
	jesper.juhl@gmail.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:50000 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S942360AbXHJVMB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Aug 2007 17:12:01 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Jesper Juhl <jesper.juhl@gmail.com>

This patch cleans up duplicate includes in
	net/ipv6/

Signed-off-by: Jesper Juhl <jesper.juhl@gmail.com>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
---

 net/ipv6/tcp_ipv6.c |    1 -
 1 files changed, 1 deletion(-)

diff -puN net/ipv6/tcp_ipv6.c~clean-up-duplicate-includes-in-net-ipv6 net/ipv6/tcp_ipv6.c
--- a/net/ipv6/tcp_ipv6.c~clean-up-duplicate-includes-in-net-ipv6
+++ a/net/ipv6/tcp_ipv6.c
@@ -56,7 +56,6 @@
 #include <net/inet_ecn.h>
 #include <net/protocol.h>
 #include <net/xfrm.h>
-#include <net/addrconf.h>
 #include <net/snmp.h>
 #include <net/dsfield.h>
 #include <net/timewait_sock.h>
_
