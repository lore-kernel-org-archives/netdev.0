From: Jani Nikula <ext-jani.1.nikula-xNZwKgViW5gAvxtiuMwx3w@public.gmane.org>
Subject: [PATCH] sunrpc: fix error path - actually return ERR_PTR() on error
Date: Fri, 12 Mar 2010 15:48:24 +0200
Message-ID: <1268401704-9034-1-git-send-email-ext-jani.1.nikula@nokia.com>
Cc: linux-nfs-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, ext-jani.1.nikula-xNZwKgViW5gAvxtiuMwx3w@public.gmane.org
To: Trond.Myklebust-HgOvQuBEEgTQT0dZR+AlfA@public.gmane.org, bfields-uC3wQj2KruNg9hUCZPvPmw@public.gmane.org, neilb-l3A5Bk7waGM@public.gmane.org,
	davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
Return-path: <linux-nfs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-nfs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Jani Nikula <ext-jani.1.nikula-xNZwKgViW5gAvxtiuMwx3w@public.gmane.org>

---

NOTE: I'm afraid I'm unable to test this; please consider this more a
bug report than a complete patch.
---
 net/sunrpc/xprtsock.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/net/sunrpc/xprtsock.c b/net/sunrpc/xprtsock.c
index 7124129..5b83ff9 100644
--- a/net/sunrpc/xprtsock.c
+++ b/net/sunrpc/xprtsock.c
@@ -2481,7 +2481,7 @@ static struct rpc_xprt *xs_setup_bc_tcp(struct xprt_create *args)
 	struct svc_sock *bc_sock;
 
 	if (!args->bc_xprt)
-		ERR_PTR(-EINVAL);
+		return ERR_PTR(-EINVAL);
 
 	xprt = xs_setup_xprt(args, xprt_tcp_slot_table_entries);
 	if (IS_ERR(xprt))
-- 
1.6.5.2

--
To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
