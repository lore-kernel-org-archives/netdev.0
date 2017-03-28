From: Aviad Yehezkel <aviadye@mellanox.com>
Subject: [RFC TLS Offload Support 03/15] tcp: export tcp_rate_check_app_limited function
Date: Tue, 28 Mar 2017 16:26:20 +0300
Message-ID: <1490707592-1430-4-git-send-email-aviadye@mellanox.com>
References: <1490707592-1430-1-git-send-email-aviadye@mellanox.com>
Cc: matanb@mellanox.com, liranl@mellanox.com, haggaie@mellanox.com,
        tom@herbertland.com, herbert@gondor.apana.org.au, nmav@gnults.org,
        fridolin.pokorny@gmail.com, ilant@mellanox.com,
        kliteyn@mellanox.com, linux-crypto@vger.kernel.org,
        saeedm@mellanox.com, aviadye@dev.mellanox.co.il
To: davem@davemloft.net, aviadye@mellanox.com, ilyal@mellanox.com,
        borisp@mellanox.com, davejwatson@fb.com, netdev@vger.kernel.org
Return-path: <linux-crypto-owner@vger.kernel.org>
In-Reply-To: <1490707592-1430-1-git-send-email-aviadye@mellanox.com>
Sender: linux-crypto-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

We will use it via tls new code.

Signed-off-by: Aviad Yehezkel <aviadye@mellanox.com>
Signed-off-by: Ilya Lesokhin <ilyal@mellanox.com>
Signed-off-by: Boris Pismenny <borisp@mellanox.com>
---
 net/ipv4/tcp_rate.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/net/ipv4/tcp_rate.c b/net/ipv4/tcp_rate.c
index 9be1581..a226f76 100644
--- a/net/ipv4/tcp_rate.c
+++ b/net/ipv4/tcp_rate.c
@@ -184,3 +184,4 @@ void tcp_rate_check_app_limited(struct sock *sk)
 		tp->app_limited =
 			(tp->delivered + tcp_packets_in_flight(tp)) ? : 1;
 }
+EXPORT_SYMBOL(tcp_rate_check_app_limited);
-- 
2.7.4
