From: Joe Perches <joe@perches.com>
Subject: [PATCH] - [15/15] - remove defconfig ptr comparisons to 0
	-	net/sunrpc
Date: Tue, 13 Nov 2007 18:05:39 -0800
Message-ID: <1195005939.5163.101.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Neil Brown <neilb@suse.de>,
	Networking Team <netdev@vger.kernel.org>,
	Trond Myklebust <trond.myklebust@fys.uio.no>,
	"J. Bruce Fields" <bfields@fieldses.org>, nfs@lists.sourceforge.net,
	Linus Torvalds <torvalds@linux-foundation.org>
To: linux-kernel <linux-kernel@vger.kernel.org>
Return-path: <nfs-bounces@lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

Remove defconfig ptr comparison to 0

Remove sparse warning: Using plain integer as NULL pointer

Signed-off-by: Joe Perches <joe@perches.com>

---

diff --git a/net/sunrpc/clnt.c b/net/sunrpc/clnt.c
index 76be83e..1600df2 100644
--- a/net/sunrpc/clnt.c
+++ b/net/sunrpc/clnt.c
@@ -157,7 +157,7 @@ static struct rpc_clnt * rpc_new_client(struct rpc_xprt *xprt, char *servname, s
 	clnt->cl_server = clnt->cl_inline_name;
 	if (len > sizeof(clnt->cl_inline_name)) {
 		char *buf = kmalloc(len, GFP_KERNEL);
-		if (buf != 0)
+		if (buf)
 			clnt->cl_server = buf;
 		else
 			len = sizeof(clnt->cl_inline_name);



-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >> http://get.splunk.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
