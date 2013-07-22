From: Andi Shyti <andi@etezian.org>
Subject: [PATCH] net: trans_rdma: remove unused function
Date: Mon, 22 Jul 2013 14:59:16 +0200
Message-ID: <1374497956-32104-1-git-send-email-andi@etezian.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: v9fs-developer@lists.sourceforge.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, andi@etezian.org
To: ericvh@gmail.com, rminnich@sandia.gov, lucho@ionkov.net,
	davem@davemloft.net
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch gets rid of the following warning:

net/9p/trans_rdma.c:594:12: warning: =E2=80=98rdma_cancelled=E2=80=99 d=
efined but not used [-Wunused-function]
 static int rdma_cancelled(struct p9_client *client, struct p9_req_t *r=
eq)

The rdma_cancelled function is not called anywhere in the kernel

Signed-off-by: Andi Shyti <andi@etezian.org>
---
 net/9p/trans_rdma.c | 11 -----------
 1 file changed, 11 deletions(-)

diff --git a/net/9p/trans_rdma.c b/net/9p/trans_rdma.c
index 928f2bb..8f68df5 100644
--- a/net/9p/trans_rdma.c
+++ b/net/9p/trans_rdma.c
@@ -588,17 +588,6 @@ static int rdma_cancel(struct p9_client *client, s=
truct p9_req_t *req)
 	return 1;
 }
=20
-/* A request has been fully flushed without a reply.
- * That means we have posted one buffer in excess.
- */
-static int rdma_cancelled(struct p9_client *client, struct p9_req_t *r=
eq)
-{
-	struct p9_trans_rdma *rdma =3D client->trans;
-
-	atomic_inc(&rdma->excess_rc);
-	return 0;
-}
-
 /**
  * trans_create_rdma - Transport method for creating atransport instan=
ce
  * @client: client instance
--=20
1.8.3.2
