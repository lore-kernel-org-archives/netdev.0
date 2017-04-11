From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: [PATCH 1/4] xfrm: remove unused struct xfrm_mgr::id
Date: Tue, 11 Apr 2017 07:53:49 +0200
Message-ID: <1491890032-28655-2-git-send-email-steffen.klassert@secunet.com>
References: <1491890032-28655-1-git-send-email-steffen.klassert@secunet.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
        Steffen Klassert <steffen.klassert@secunet.com>,
        <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([62.96.220.36]:56544 "EHLO a.mx.secunet.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751273AbdDKF71 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 11 Apr 2017 01:59:27 -0400
In-Reply-To: <1491890032-28655-1-git-send-email-steffen.klassert@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexey Dobriyan <adobriyan@gmail.com>

Signed-off-by: Alexey Dobriyan <adobriyan@gmail.com>
Signed-off-by: Steffen Klassert <steffen.klassert@secunet.com>
---
 include/net/xfrm.h   | 1 -
 net/key/af_key.c     | 1 -
 net/xfrm/xfrm_user.c | 1 -
 3 files changed, 3 deletions(-)

diff --git a/include/net/xfrm.h b/include/net/xfrm.h
index 14d82bf..6e03a1a 100644
--- a/include/net/xfrm.h
+++ b/include/net/xfrm.h
@@ -586,7 +586,6 @@ struct xfrm_migrate {
 
 struct xfrm_mgr {
 	struct list_head	list;
-	char			*id;
 	int			(*notify)(struct xfrm_state *x, const struct km_event *c);
 	int			(*acquire)(struct xfrm_state *x, struct xfrm_tmpl *, struct xfrm_policy *xp);
 	struct xfrm_policy	*(*compile_policy)(struct sock *sk, int opt, u8 *data, int len, int *dir);
diff --git a/net/key/af_key.c b/net/key/af_key.c
index c6252ed..60cf2fb 100644
--- a/net/key/af_key.c
+++ b/net/key/af_key.c
@@ -3792,7 +3792,6 @@ static inline void pfkey_exit_proc(struct net *net)
 
 static struct xfrm_mgr pfkeyv2_mgr =
 {
-	.id		= "pfkeyv2",
 	.notify		= pfkey_send_notify,
 	.acquire	= pfkey_send_acquire,
 	.compile_policy	= pfkey_compile_policy,
diff --git a/net/xfrm/xfrm_user.c b/net/xfrm/xfrm_user.c
index 9705c27..8e696ea 100644
--- a/net/xfrm/xfrm_user.c
+++ b/net/xfrm/xfrm_user.c
@@ -3101,7 +3101,6 @@ static bool xfrm_is_alive(const struct km_event *c)
 }
 
 static struct xfrm_mgr netlink_mgr = {
-	.id		= "netlink",
 	.notify		= xfrm_send_state_notify,
 	.acquire	= xfrm_send_acquire,
 	.compile_policy	= xfrm_compile_policy,
-- 
2.7.4
