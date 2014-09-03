From: Andy Zhou <azhou@nicira.com>
Subject: [net-next] l2tp: fix missing line continuation
Date: Wed,  3 Sep 2014 13:16:54 -0700
Message-ID: <1409775414-11568-1-git-send-email-azhou@nicira.com>
Cc: netdev@vger.kernel.org, Andy Zhou <azhou@nicira.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from na6sys009bog003.obsmtp.com ([74.125.150.46]:48052 "HELO
	na6sys009bog003.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1754174AbaICUW3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Sep 2014 16:22:29 -0400
Received: by mail-pa0-f47.google.com with SMTP id hz1so18331495pad.34
        for <netdev@vger.kernel.org>; Wed, 03 Sep 2014 13:22:28 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This syntax error was covered by L2TP_REFCNT_DEBUG not being set by
default.

Signed-off-by: Andy Zhou <azhou@nicira.com>
---
 net/l2tp/l2tp_core.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/l2tp/l2tp_core.c b/net/l2tp/l2tp_core.c
index 797c0af..2aa2b6c 100644
--- a/net/l2tp/l2tp_core.c
+++ b/net/l2tp/l2tp_core.c
@@ -148,7 +148,7 @@ do {									\
 		 atomic_read(&_t->ref_count));				\
 	l2tp_tunnel_inc_refcount_1(_t);					\
 } while (0)
-#define l2tp_tunnel_dec_refcount(_t)
+#define l2tp_tunnel_dec_refcount(_t)					\
 do {									\
 	pr_debug("l2tp_tunnel_dec_refcount: %s:%d %s: cnt=%d\n",	\
 		 __func__, __LINE__, (_t)->name,			\
-- 
1.7.9.5
