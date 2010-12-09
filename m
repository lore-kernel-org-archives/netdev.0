From: Joe Perches <joe@perches.com>
Subject: [PATCH 15/15] ipv6: Remove duplicate unlikely from IS_ERR
Date: Thu,  9 Dec 2010 12:04:08 -0800
Message-ID: <ee5d2f9776ec2076b41c2abb23cdde76248602b2.1291923889.git.joe@perches.com>
References: <1291906801-1389-2-git-send-email-tklauser@distanz.ch>
Cc: Jiri Kosina <trivial@kernel.org>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	"Pekka Savola (ipv6)" <pekkas@netcore.fi>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yosh
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1291906801-1389-2-git-send-email-tklauser@distanz.ch>
In-Reply-To: <cover.1291923888.git.joe@perches.com>
References: <cover.1291923888.git.joe@perches.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

IS_ERR already uses unlikely, remove unlikely from the call sites.

Signed-off-by: Joe Perches <joe@perches.com>
---
 net/ipv6/af_inet6.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/net/ipv6/af_inet6.c b/net/ipv6/af_inet6.c
index 54e8e42..059a3de 100644
--- a/net/ipv6/af_inet6.c
+++ b/net/ipv6/af_inet6.c
@@ -810,7 +810,7 @@ static struct sk_buff *ipv6_gso_segment(struct sk_buff *skb, int features)
 	}
 	rcu_read_unlock();
 
-	if (unlikely(IS_ERR(segs)))
+	if (IS_ERR(segs))
 		goto out;
 
 	for (skb = segs; skb; skb = skb->next) {
-- 
1.7.3.3.464.gf80b6
