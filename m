From: LABBE Corentin <clabbe.montjoie@gmail.com>
Subject: [PATCH 08/11] net: bluetooth: change the len parameter of sco_send_frame() to size_t
Date: Fri, 23 Oct 2015 14:10:33 +0200
Message-ID: <1445602236-24130-9-git-send-email-clabbe.montjoie@gmail.com>
References: <1445602236-24130-1-git-send-email-clabbe.montjoie@gmail.com>
Cc: LABBE Corentin <clabbe.montjoie@gmail.com>,
	linux-bluetooth@vger.kernel.org, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: davem@davemloft.net, gustavo@padovan.org, johan.hedberg@gmail.com,
	marcel@holtmann.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1445602236-24130-1-git-send-email-clabbe.montjoie@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

len is used in operation/function that wait for unsigned value.
Furthermore the only one call of sco_send_frame give a size_t as argument.
So the parameter need to be set as size_t.

Signed-off-by: LABBE Corentin <clabbe.montjoie@gmail.com>
---
 net/bluetooth/sco.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/bluetooth/sco.c b/net/bluetooth/sco.c
index f315c8d..1ae4b36 100644
--- a/net/bluetooth/sco.c
+++ b/net/bluetooth/sco.c
@@ -268,7 +268,7 @@ done:
 	return err;
 }
 
-static int sco_send_frame(struct sock *sk, struct msghdr *msg, int len)
+static int sco_send_frame(struct sock *sk, struct msghdr *msg, size_t len)
 {
 	struct sco_conn *conn = sco_pi(sk)->conn;
 	struct sk_buff *skb;
-- 
2.4.10
