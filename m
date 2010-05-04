From: Johannes Weiner <jw-QdrG9jWwCLEAvxtiuMwx3w@public.gmane.org>
Subject: [patch] sunrpc: add missing return statement
Date: Tue, 4 May 2010 13:59:57 +0200
Message-ID: <20100504115759.266396633@emlix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Alexandros Batsakis <batsakis-HgOvQuBEEgTQT0dZR+AlfA@public.gmane.org>,
	linux-nfs-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <linux-nfs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
Sender: linux-nfs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

f300bab "nfsd41: sunrpc: add new xprt class for nfsv4.1 backchannel"
introduced an error case branch that lacks an actual `return' keyword
before the return value.  Add it.

Signed-off-by: Johannes Weiner <jw-QdrG9jWwCLEAvxtiuMwx3w@public.gmane.org>
Cc: Alexandros Batsakis <batsakis-HgOvQuBEEgTQT0dZR+AlfA@public.gmane.org>
---
 net/sunrpc/xprtsock.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

--- a/net/sunrpc/xprtsock.c
+++ b/net/sunrpc/xprtsock.c
@@ -2444,7 +2444,7 @@ static struct rpc_xprt *xs_setup_bc_tcp(
 	struct svc_sock *bc_sock;
 
 	if (!args->bc_xprt)
-		ERR_PTR(-EINVAL);
+		return ERR_PTR(-EINVAL);
 
 	xprt = xs_setup_xprt(args, xprt_tcp_slot_table_entries);
 	if (IS_ERR(xprt))
--
To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
