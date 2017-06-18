From: Christos Gkekas <chris.gekas@gmail.com>
Subject: [PATCH] pptp: Remove unused variable in pptp_release()
Date: Sun, 18 Jun 2017 16:41:40 +0100
Message-ID: <1497800500-17897-1-git-send-email-chris.gekas@gmail.com>
Cc: Christos Gkekas <chris.gekas@gmail.com>
To: Dmitry Kozlov <xeb@mail.ru>, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Variable opt in pptp_release() is set but never used, thus needs to be
removed.

Signed-off-by: Christos Gkekas <chris.gekas@gmail.com>
---
 drivers/net/ppp/pptp.c | 2 --
 1 file changed, 2 deletions(-)

diff --git a/drivers/net/ppp/pptp.c b/drivers/net/ppp/pptp.c
index 1951b10..5b0fd89 100644
--- a/drivers/net/ppp/pptp.c
+++ b/drivers/net/ppp/pptp.c
@@ -506,7 +506,6 @@ static int pptp_release(struct socket *sock)
 {
 	struct sock *sk = sock->sk;
 	struct pppox_sock *po;
-	struct pptp_opt *opt;
 	int error = 0;
 
 	if (!sk)
@@ -520,7 +519,6 @@ static int pptp_release(struct socket *sock)
 	}
 
 	po = pppox_sk(sk);
-	opt = &po->proto.pptp;
 	del_chan(po);
 
 	pppox_unbind_sock(sk);
-- 
2.7.4
