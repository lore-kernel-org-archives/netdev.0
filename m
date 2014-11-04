From: Fabian Frederick <fabf@skynet.be>
Subject: [PATCH/TRIVIAL 1/1 net-next] udp: remove blank line between set and test
Date: Tue,  4 Nov 2014 23:11:19 +0100
Message-ID: <1415139079-7931-1-git-send-email-fabf@skynet.be>
Cc: Joe Perches <joe@perches.com>, Fabian Frederick <fabf@skynet.be>,
	"David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>,
	Jiri Kosina <trivial@kernel.org>, netdev@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Suggested-by: Joe Perches <joe@perches.com>
Signed-off-by: Fabian Frederick <fabf@skynet.be>
---
 net/ipv4/udp.c | 1 -
 1 file changed, 1 deletion(-)

diff --git a/net/ipv4/udp.c b/net/ipv4/udp.c
index cf0cece..3f001db 100644
--- a/net/ipv4/udp.c
+++ b/net/ipv4/udp.c
@@ -1784,7 +1784,6 @@ int __udp4_lib_rcv(struct sk_buff *skb, struct udp_table *udptable,
 				saddr, daddr, udptable);
 
 	sk = __udp4_lib_lookup_skb(skb, uh->source, uh->dest, udptable);
-
 	if (sk != NULL) {
 		int ret;
 
-- 
1.9.3
