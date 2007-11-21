From: akpm@linux-foundation.org
Subject: [patch 4/4] Net: sunrpc, remove SPIN_LOCK_UNLOCKED
Date: Wed, 21 Nov 2007 15:02:15 -0800
Message-ID: <200711212302.lALN2G3A013610@imap1.linux-foundation.org>
Cc: netdev@vger.kernel.org, akpm@linux-foundation.org,
	jirislaby@gmail.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:35723 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753863AbXKUXCU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 Nov 2007 18:02:20 -0500
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Jiri Slaby <jirislaby@gmail.com>

sunrpc, remove SPIN_LOCK_UNLOCKED

SPIN_LOCK_UNLOCKED is deprecated, use DEFINE_SPINLOCK instead

Signed-off-by: Jiri Slaby <jirislaby@gmail.com>
Cc: "David S. Miller" <davem@davemloft.net>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
---

 net/sunrpc/xprt.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff -puN net/sunrpc/xprt.c~net-sunrpc-remove-spin_lock_unlocked net/sunrpc/xprt.c
--- a/net/sunrpc/xprt.c~net-sunrpc-remove-spin_lock_unlocked
+++ a/net/sunrpc/xprt.c
@@ -62,7 +62,7 @@ static inline void	do_xprt_reserve(struc
 static void	xprt_connect_status(struct rpc_task *task);
 static int      __xprt_get_cong(struct rpc_xprt *, struct rpc_task *);
 
-static spinlock_t xprt_list_lock = SPIN_LOCK_UNLOCKED;
+static DEFINE_SPINLOCK(xprt_list_lock);
 static LIST_HEAD(xprt_list);
 
 /*
_
