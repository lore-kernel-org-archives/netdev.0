From: Jiri Slaby <jirislaby@gmail.com>
Subject: [PATCH 5/5] Net: sunrpc, remove SPIN_LOCK_UNLOCKED
Date: Fri, 9 Nov 2007 18:34:06 -0500
Message-ID: <5566687663573801@pripojeni.net>
References: <4827138842526222333@pripojeni.net>
Cc: <linux-kernel@vger.kernel.org>
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1763218AbXKIXeU@vger.kernel.org>
In-reply-to: <4827138842526222333@pripojeni.net>
Cc: <netdev@vger.kernel.org>
Cc: <tom@opengridcomputing.com>
Cc: <okir@monad.swb.de>
Cc: <cel@netapp.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

sunrpc, remove SPIN_LOCK_UNLOCKED

SPIN_LOCK_UNLOCKED is deprecated, use DEFINE_SPINLOCK instead

Signed-off-by: Jiri Slaby <jirislaby@gmail.com>

---
commit d5e782e62a4fe2663a012571c3444445d9887b02
tree b993038b020d8c619f6ffdad412fbb992c073513
parent 828042d12cc0aa515e049889aa76d4066df100c0
author Jiri Slaby <jirislaby@gmail.com> Thu, 25 Oct 2007 12:00:13 +0200
committer Jiri Slaby <jirislaby@gmail.com> Thu, 25 Oct 2007 12:00:13 +0200

 net/sunrpc/xprt.c     |    2 +-
 2 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/sunrpc/xprt.c b/net/sunrpc/xprt.c
index 282a9a2..cd641c8 100644
--- a/net/sunrpc/xprt.c
+++ b/net/sunrpc/xprt.c
@@ -62,7 +62,7 @@ static inline void	do_xprt_reserve(struct rpc_task *);
 static void	xprt_connect_status(struct rpc_task *task);
 static int      __xprt_get_cong(struct rpc_xprt *, struct rpc_task *);
 
-static spinlock_t xprt_list_lock = SPIN_LOCK_UNLOCKED;
+static DEFINE_SPINLOCK(xprt_list_lock);
 static LIST_HEAD(xprt_list);
 
 /*
