From: Randy Dunlap <rdunlap-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org>
Subject: [PATCH] sunrpc: fix clnt.c kernel-doc warning
Date: Tue, 06 Nov 2012 17:08:47 -0800
Message-ID: <5099B49F.5070701@infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Trond Myklebust <Trond.Myklebust-HgOvQuBEEgTQT0dZR+AlfA@public.gmane.org>,
	"J. Bruce Fields" <bfields-uC3wQj2KruNg9hUCZPvPmw@public.gmane.org>, linux-nfs-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: "netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Return-path: <linux-nfs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-nfs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Randy Dunlap <rdunlap-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org>

Fix new kernel-doc warnings in clnt.c:

Warning(net/sunrpc/clnt.c:561): No description found for parameter 'flavor'
Warning(net/sunrpc/clnt.c:561): Excess function parameter 'auth' description in 'rpc_clone_client_set_auth'

Signed-off-by: Randy Dunlap <rdunlap-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org>
Cc:	Trond Myklebust <Trond.Myklebust-HgOvQuBEEgTQT0dZR+AlfA@public.gmane.org>
Cc:	"J. Bruce Fields" <bfields-uC3wQj2KruNg9hUCZPvPmw@public.gmane.org>
Cc:	linux-nfs-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
---
 net/sunrpc/clnt.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

--- lnx-37-rc4.orig/net/sunrpc/clnt.c
+++ lnx-37-rc4/net/sunrpc/clnt.c
@@ -552,7 +552,7 @@ EXPORT_SYMBOL_GPL(rpc_clone_client);
  * rpc_clone_client_set_auth - Clone an RPC client structure and set its auth
  *
  * @clnt: RPC client whose parameters are copied
- * @auth: security flavor for new client
+ * @flavor: security flavor for new client
  *
  * Returns a fresh RPC client or an ERR_PTR.
  */
--
To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
