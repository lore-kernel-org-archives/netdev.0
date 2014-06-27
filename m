From: Fabian Frederick <fabf@skynet.be>
Subject: [PATCH 1/1] net/caif/caif_socket.c: remove unnecessary null test before debugfs_remove_recursive
Date: Fri, 27 Jun 2014 23:07:43 +0200
Message-ID: <1403903263-13355-1-git-send-email-fabf@skynet.be>
Cc: Fabian Frederick <fabf@skynet.be>,
	Dmitry Tarnyagin <dmitry.tarnyagin@lockless.no>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

based on checkpatch:
"debugfs_remove_recursive(NULL) is safe this check is probably not required"

Cc: Dmitry Tarnyagin <dmitry.tarnyagin@lockless.no>
Cc: "David S. Miller" <davem@davemloft.net>
Cc: netdev@vger.kernel.org
Signed-off-by: Fabian Frederick <fabf@skynet.be>
---
 net/caif/caif_socket.c | 3 +--
 1 file changed, 1 insertion(+), 2 deletions(-)

diff --git a/net/caif/caif_socket.c b/net/caif/caif_socket.c
index e843709..43f750e 100644
--- a/net/caif/caif_socket.c
+++ b/net/caif/caif_socket.c
@@ -908,8 +908,7 @@ static int caif_release(struct socket *sock)
 	sock->sk = NULL;
 
 	WARN_ON(IS_ERR(cf_sk->debugfs_socket_dir));
-	if (cf_sk->debugfs_socket_dir != NULL)
-		debugfs_remove_recursive(cf_sk->debugfs_socket_dir);
+	debugfs_remove_recursive(cf_sk->debugfs_socket_dir);
 
 	lock_sock(&(cf_sk->sk));
 	sk->sk_state = CAIF_DISCONNECTED;
-- 
1.8.4.5
