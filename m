From: akpm@osdl.org
Subject: [patch 07/13] security/selinux/hooks.c: make 4 functions static
Date: Mon, 14 Aug 2006 23:03:41 -0700
Message-ID: <200608150603.k7F63f8D012942@shell0.pdx.osdl.net>
Cc: netdev@vger.kernel.org, akpm@osdl.org, bunk@stusta.de,
	jmorris@namei.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:7317 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S965173AbWHOGG7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Aug 2006 02:06:59 -0400
To: davem@davemloft.net
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Adrian Bunk <bunk@stusta.de>

This patch makes four needlessly global functions static.

(akpm: applicable to the selinux updates in net-2.6.19.git)

Signed-off-by: Adrian Bunk <bunk@stusta.de>
Acked-by: James Morris <jmorris@namei.org>
Cc: "David S. Miller" <davem@davemloft.net>
Signed-off-by: Andrew Morton <akpm@osdl.org>
---

 security/selinux/hooks.c |   12 +++++++-----
 1 file changed, 7 insertions(+), 5 deletions(-)

diff -puN security/selinux/hooks.c~security-selinux-hooksc-make-4-functions-static security/selinux/hooks.c
--- a/security/selinux/hooks.c~security-selinux-hooksc-make-4-functions-static
+++ a/security/selinux/hooks.c
@@ -3598,7 +3598,7 @@ static void selinux_sk_getsecid(struct s
 	}
 }
 
-void selinux_sock_graft(struct sock* sk, struct socket *parent)
+static void selinux_sock_graft(struct sock* sk, struct socket *parent)
 {
 	struct inode_security_struct *isec = SOCK_INODE(parent)->i_security;
 	struct sk_security_struct *sksec = sk->sk_security;
@@ -3608,8 +3608,8 @@ void selinux_sock_graft(struct sock* sk,
 	selinux_netlbl_sock_graft(sk, parent);
 }
 
-int selinux_inet_conn_request(struct sock *sk, struct sk_buff *skb,
-					   struct request_sock *req)
+static int selinux_inet_conn_request(struct sock *sk, struct sk_buff *skb,
+				     struct request_sock *req)
 {
 	struct sk_security_struct *sksec = sk->sk_security;
 	int err;
@@ -3638,7 +3638,8 @@ int selinux_inet_conn_request(struct soc
 	return 0;
 }
 
-void selinux_inet_csk_clone(struct sock *newsk, const struct request_sock *req)
+static void selinux_inet_csk_clone(struct sock *newsk,
+				   const struct request_sock *req)
 {
 	struct sk_security_struct *newsksec = newsk->sk_security;
 
@@ -3649,7 +3650,8 @@ void selinux_inet_csk_clone(struct sock 
 	   time it will have been created and available. */
 }
 
-void selinux_req_classify_flow(const struct request_sock *req, struct flowi *fl)
+static void selinux_req_classify_flow(const struct request_sock *req,
+				      struct flowi *fl)
 {
 	fl->secid = req->secid;
 }
_
