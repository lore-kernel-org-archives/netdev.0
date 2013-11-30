From: Weng Meiling <wengmeiling.weng-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
Subject: [PATCH] sunrpc: fix some typos
Date: Sat, 30 Nov 2013 17:56:44 +0800
Message-ID: <5299B65C.4070700@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Li Zefan <lizefan-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>,
	Huang Qiang <h.huangqiang-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
To: <linux-nfs-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	<netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, "J. Bruce Fields" <bfields-uC3wQj2KruNg9hUCZPvPmw@public.gmane.org>,
	<Trond.Myklebust-HgOvQuBEEgTQT0dZR+AlfA@public.gmane.org>, <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <linux-nfs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-nfs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org


From: Weng Meiling <wengmeiling.weng-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>

Signed-off-by: Weng Meiling <wengmeiling.weng-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
---
 include/linux/sunrpc/svc.h | 2 +-
 net/sunrpc/xprtsock.c      | 7 +++----
 2 files changed, 4 insertions(+), 5 deletions(-)

diff --git a/include/linux/sunrpc/svc.h b/include/linux/sunrpc/svc.h
index 6eecfc2..b6316423 100644
--- a/include/linux/sunrpc/svc.h
+++ b/include/linux/sunrpc/svc.h
@@ -368,7 +368,7 @@ struct svc_program {
 	struct svc_program *	pg_next;	/* other programs (same xprt) */
 	u32			pg_prog;	/* program number */
 	unsigned int		pg_lovers;	/* lowest version */
-	unsigned int		pg_hivers;	/* lowest version */
+	unsigned int		pg_hivers;	/* highest version */
 	unsigned int		pg_nvers;	/* number of versions */
 	struct svc_version **	pg_vers;	/* version array */
 	char *			pg_name;	/* service name */
diff --git a/net/sunrpc/xprtsock.c b/net/sunrpc/xprtsock.c
index dd9d295..0f4f391 100644
--- a/net/sunrpc/xprtsock.c
+++ b/net/sunrpc/xprtsock.c
@@ -2932,10 +2932,9 @@ static struct rpc_xprt *xs_setup_bc_tcp(struct xprt_create *args)

 	/*
 	 * Once we've associated a backchannel xprt with a connection,
-	 * we want to keep it around as long as long as the connection
-	 * lasts, in case we need to start using it for a backchannel
-	 * again; this reference won't be dropped until bc_xprt is
-	 * destroyed.
+	 * we want to keep it around as long as the connection lasts,
+	 * in case we need to start using it for a backchannel again;
+	 * this reference won't be dropped until bc_xprt is destroyed.
 	 */
 	xprt_get(xprt);
 	args->bc_xprt->xpt_bc_xprt = xprt;
-- 
1.8.3


--
To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
