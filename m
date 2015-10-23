From: LABBE Corentin <clabbe.montjoie@gmail.com>
Subject: [PATCH 05/11] net: irda: change chunk from int to size_t
Date: Fri, 23 Oct 2015 14:10:30 +0200
Message-ID: <1445602236-24130-6-git-send-email-clabbe.montjoie@gmail.com>
References: <1445602236-24130-1-git-send-email-clabbe.montjoie@gmail.com>
Cc: LABBE Corentin <clabbe.montjoie@gmail.com>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: davem@davemloft.net, samuel@sortiz.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1445602236-24130-1-git-send-email-clabbe.montjoie@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

chunk cannot be negative and is use in operation/function that
wait for unsigned value. This patch set it as size_t.

Signed-off-by: LABBE Corentin <clabbe.montjoie@gmail.com>
---
 net/irda/af_irda.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/irda/af_irda.c b/net/irda/af_irda.c
index fae6822..180cca2 100644
--- a/net/irda/af_irda.c
+++ b/net/irda/af_irda.c
@@ -1424,7 +1424,7 @@ static int irda_recvmsg_stream(struct socket *sock, struct msghdr *msg,
 	timeo = sock_rcvtimeo(sk, noblock);
 
 	do {
-		int chunk;
+		size_t chunk;
 		struct sk_buff *skb = skb_dequeue(&sk->sk_receive_queue);
 
 		if (skb == NULL) {
-- 
2.4.10
