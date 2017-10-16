From: Colin King <colin.king@canonical.com>
Subject: [PATCH] sunrcp: make function _svc_create_xprt static
Date: Mon, 16 Oct 2017 14:40:21 +0100
Message-ID: <20171016134021.15702-1-colin.king@canonical.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit
Cc: kernel-janitors@vger.kernel.org, linux-kernel@vger.kernel.org
To: "J . Bruce Fields" <bfields@fieldses.org>,
        Jeff Layton <jlayton@poochiereds.net>,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        Anna Schumaker <anna.schumaker@netapp.com>,
        "David S . Miller" <davem@davemloft.net>,
        linux-nfs@vger.kernel.org, netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Colin Ian King <colin.king@canonical.com>

The function _svc_create_xprt is local to the source and
does not need to be in global scope, so make it static.

Cleans up sparse warning:
symbol '_svc_create_xprt' was not declared. Should it be static?

Signed-off-by: Colin Ian King <colin.king@canonical.com>
---
 net/sunrpc/svc_xprt.c | 6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/net/sunrpc/svc_xprt.c b/net/sunrpc/svc_xprt.c
index d16a8b423c20..18e87791350f 100644
--- a/net/sunrpc/svc_xprt.c
+++ b/net/sunrpc/svc_xprt.c
@@ -250,9 +250,9 @@ void svc_add_new_perm_xprt(struct svc_serv *serv, struct svc_xprt *new)
 	svc_xprt_received(new);
 }
 
-int _svc_create_xprt(struct svc_serv *serv, const char *xprt_name,
-		    struct net *net, const int family,
-		    const unsigned short port, int flags)
+static int _svc_create_xprt(struct svc_serv *serv, const char *xprt_name,
+			    struct net *net, const int family,
+			    const unsigned short port, int flags)
 {
 	struct svc_xprt_class *xcl;
 
-- 
2.14.1
