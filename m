From: Camelia Groza <camelia.groza@gmail.com>
Subject: [PATCH] inet: fix spacing in assignment
Date: Thu, 11 Jul 2013 09:55:51 +0300
Message-ID: <1373525751-9724-1-git-send-email-camelia.groza@gmail.com>
Cc: kuznet@ms2.inr.ac.ru, jmorris@namei.org, yoshfuji@linux-ipv6.org,
	kaber@trash.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	Camelia Groza <camelia.groza@gmail.com>
To: davem@davemloft.net
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Found using checkpatch.pl

Signed-off-by: Camelia Groza <camelia.groza@gmail.com>
---
 net/ipv4/inet_hashtables.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/ipv4/inet_hashtables.c b/net/ipv4/inet_hashtables.c
index 6af375a..7bd8983 100644
--- a/net/ipv4/inet_hashtables.c
+++ b/net/ipv4/inet_hashtables.c
@@ -467,7 +467,7 @@ void inet_unhash(struct sock *sk)
 		lock = inet_ehash_lockp(hashinfo, sk->sk_hash);
 
 	spin_lock_bh(lock);
-	done =__sk_nulls_del_node_init_rcu(sk);
+	done = __sk_nulls_del_node_init_rcu(sk);
 	if (done)
 		sock_prot_inuse_add(sock_net(sk), sk->sk_prot, -1);
 	spin_unlock_bh(lock);
-- 
1.7.10.4
