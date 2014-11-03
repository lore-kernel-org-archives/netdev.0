From: James Brown <roguelazer@roguelazer.com>
Subject: [PATCH] ipv4: fix comment in net/ipv4/tcp_input.c to reference the correct RFC
Date: Sun,  2 Nov 2014 19:11:00 -0800
Message-ID: <1414984260-26020-1-git-send-email-roguelazer@roguelazer.com>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	James Brown <roguelazer@roguelazer.com>
To: "David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

RFC 5691 has to do with MPEG surround-sound; RFC 5961 has to do
with hardening TCP against in-window spoofing attacks

Signed-off-by: James Brown <roguelazer@roguelazer.com>
---
 net/ipv4/tcp_input.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index a12b455..d285962 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -5028,7 +5028,7 @@ static bool tcp_validate_incoming(struct sock *sk, struct sk_buff *skb,
 	/* step 3: check security and precedence [ignored] */
 
 	/* step 4: Check for a SYN
-	 * RFC 5691 4.2 : Send a challenge ack
+	 * RFC 5961 4.2 : Send a challenge ack
 	 */
 	if (th->syn) {
 syn_challenge:
-- 
2.1.2
