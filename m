From: Alexey Dobriyan <adobriyan@gmail.com>
Subject: [PATCH] xfrm: remove unused struct xfrm_mgr::id
Date: Fri, 24 Mar 2017 01:29:40 +0300
Message-ID: <20170323222940.GB31372@avx2>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: herbert@gondor.apana.org.au, davem@davemloft.net,
        netdev@vger.kernel.org
To: steffen.klassert@secunet.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f67.google.com ([209.85.215.67]:36815 "EHLO
        mail-lf0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1756022AbdCWW3u (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 23 Mar 2017 18:29:50 -0400
Received: by mail-lf0-f67.google.com with SMTP id g70so18302379lfh.3
        for <netdev@vger.kernel.org>; Thu, 23 Mar 2017 15:29:48 -0700 (PDT)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Alexey Dobriyan <adobriyan@gmail.com>
---

 include/net/xfrm.h   |    1 -
 net/key/af_key.c     |    1 -
 net/xfrm/xfrm_user.c |    1 -
 3 files changed, 3 deletions(-)

--- a/include/net/xfrm.h
+++ b/include/net/xfrm.h
@@ -586,7 +586,6 @@ struct xfrm_migrate {
 
 struct xfrm_mgr {
 	struct list_head	list;
-	char			*id;
 	int			(*notify)(struct xfrm_state *x, const struct km_event *c);
 	int			(*acquire)(struct xfrm_state *x, struct xfrm_tmpl *, struct xfrm_policy *xp);
 	struct xfrm_policy	*(*compile_policy)(struct sock *sk, int opt, u8 *data, int len, int *dir);
--- a/net/key/af_key.c
+++ b/net/key/af_key.c
@@ -3792,7 +3792,6 @@ static inline void pfkey_exit_proc(struct net *net)
 
 static struct xfrm_mgr pfkeyv2_mgr =
 {
-	.id		= "pfkeyv2",
 	.notify		= pfkey_send_notify,
 	.acquire	= pfkey_send_acquire,
 	.compile_policy	= pfkey_compile_policy,
--- a/net/xfrm/xfrm_user.c
+++ b/net/xfrm/xfrm_user.c
@@ -3101,7 +3101,6 @@ static bool xfrm_is_alive(const struct km_event *c)
 }
 
 static struct xfrm_mgr netlink_mgr = {
-	.id		= "netlink",
 	.notify		= xfrm_send_state_notify,
 	.acquire	= xfrm_send_acquire,
 	.compile_policy	= xfrm_compile_policy,
