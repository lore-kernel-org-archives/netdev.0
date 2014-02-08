From: Rashika Kheria <rashika.kheria@gmail.com>
Subject: [PATCH 13/13] net: Mark functions as static in net/sunrpc/svc_xprt.c
Date: Sun, 9 Feb 2014 01:40:54 +0530
Message-ID: <259f3dc38d7115eccf3aaa2aa7de2414a47f90a2.1391888654.git.rashika.kheria@gmail.com>
References: <6f029c895035908595957fb16ab445c82793c77d.1391888654.git.rashika.kheria@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Trond Myklebust <trond.myklebust@primarydata.com>,
	"J. Bruce Fields" <bfields@fieldses.org>,
	"David S. Miller" <davem@davemloft.net>, linux-nfs@vger.kernel.org,
	netdev@vger.kernel.org, josh@joshtriplett.org
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <6f029c895035908595957fb16ab445c82793c77d.1391888654.git.rashika.kheria@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Mark functions as static in net/sunrpc/svc_xprt.c because they are not
used outside this file.

This eliminates the following warning in net/sunrpc/svc_xprt.c:
net/sunrpc/svc_xprt.c:574:5: warning: no previous prototype for =E2=80=98=
svc_alloc_arg=E2=80=99 [-Wmissing-prototypes]
net/sunrpc/svc_xprt.c:615:18: warning: no previous prototype for =E2=80=
=98svc_get_next_xprt=E2=80=99 [-Wmissing-prototypes]
net/sunrpc/svc_xprt.c:694:6: warning: no previous prototype for =E2=80=98=
svc_add_new_temp_xprt=E2=80=99 [-Wmissing-prototypes]

Signed-off-by: Rashika Kheria <rashika.kheria@gmail.com>
---
 net/sunrpc/svc_xprt.c |    6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/net/sunrpc/svc_xprt.c b/net/sunrpc/svc_xprt.c
index 80a6640..06c6ff0 100644
--- a/net/sunrpc/svc_xprt.c
+++ b/net/sunrpc/svc_xprt.c
@@ -571,7 +571,7 @@ static void svc_check_conn_limits(struct svc_serv *=
serv)
 	}
 }
=20
-int svc_alloc_arg(struct svc_rqst *rqstp)
+static int svc_alloc_arg(struct svc_rqst *rqstp)
 {
 	struct svc_serv *serv =3D rqstp->rq_server;
 	struct xdr_buf *arg;
@@ -612,7 +612,7 @@ int svc_alloc_arg(struct svc_rqst *rqstp)
 	return 0;
 }
=20
-struct svc_xprt *svc_get_next_xprt(struct svc_rqst *rqstp, long timeou=
t)
+static struct svc_xprt *svc_get_next_xprt(struct svc_rqst *rqstp, long=
 timeout)
 {
 	struct svc_xprt *xprt;
 	struct svc_pool		*pool =3D rqstp->rq_pool;
@@ -691,7 +691,7 @@ struct svc_xprt *svc_get_next_xprt(struct svc_rqst =
*rqstp, long timeout)
 	return xprt;
 }
=20
-void svc_add_new_temp_xprt(struct svc_serv *serv, struct svc_xprt *new=
xpt)
+static void svc_add_new_temp_xprt(struct svc_serv *serv, struct svc_xp=
rt *newxpt)
 {
 	spin_lock_bh(&serv->sv_lock);
 	set_bit(XPT_TEMP, &newxpt->xpt_flags);
--=20
1.7.9.5
