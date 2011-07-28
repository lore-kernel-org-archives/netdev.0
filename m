From: Randy Dunlap <rdunlap@xenotime.net>
Subject: [PATCH] net: fix new sunrpc kernel-doc warning
Date: Thu, 28 Jul 2011 09:54:36 -0700
Message-ID: <20110728095436.6fdb3eb4.rdunlap@xenotime.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from oproxy4-pub.bluehost.com ([69.89.21.11]:42579 "HELO
	oproxy4-pub.bluehost.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with SMTP id S1755300Ab1G1Qyj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Jul 2011 12:54:39 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Randy Dunlap <rdunlap@xenotime.net>

Fix new kernel-doc warning in sunrpc:

Warning(net/sunrpc/xprt.c:196): No description found for parameter 'xprt'

Signed-off-by: Randy Dunlap <rdunlap@xenotime.net>
---
 net/sunrpc/xprt.c |    1 +
 1 file changed, 1 insertion(+)

--- linux-3.0-git10.orig/net/sunrpc/xprt.c
+++ linux-3.0-git10/net/sunrpc/xprt.c
@@ -187,6 +187,7 @@ EXPORT_SYMBOL_GPL(xprt_load_transport);
 /**
  * xprt_reserve_xprt - serialize write access to transports
  * @task: task that is requesting access to the transport
+ * @xprt: pointer to the target transport
  *
  * This prevents mixing the payload of separate requests, and prevents
  * transport connects from colliding with writes.  No congestion control
