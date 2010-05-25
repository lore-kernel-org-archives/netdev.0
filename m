From: Randy Dunlap <randy.dunlap@oracle.com>
Subject: [PATCH] sock.h: fix kernel-doc warning
Date: Mon, 24 May 2010 22:22:25 -0700
Message-ID: <20100524222225.0fc298eb.randy.dunlap@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net
To: netdev <netdev@vger.kernel.org>, akpm <akpm@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rcsinet10.oracle.com ([148.87.113.121]:17476 "EHLO
	rcsinet10.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751098Ab0EYFWz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 May 2010 01:22:55 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Randy Dunlap <randy.dunlap@oracle.com>

Fix sock.h kernel-doc warning:
Warning(include/net/sock.h:1438): No description found for parameter 'wq'

Signed-off-by: Randy Dunlap <randy.dunlap@oracle.com>
---
 include/net/sock.h |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

--- lnx-2634-g8-kerndoc.orig/include/net/sock.h
+++ lnx-2634-g8-kerndoc/include/net/sock.h
@@ -1404,7 +1404,7 @@ static inline int sk_has_allocations(con
 
 /**
  * wq_has_sleeper - check if there are any waiting processes
- * @sk: struct socket_wq
+ * @wq: struct socket_wq
  *
  * Returns true if socket_wq has waiting processes
  *
