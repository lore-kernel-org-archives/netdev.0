From: Fabian Frederick <fabf@skynet.be>
Subject: [PATCH V2 net-next] esp4: remove assignment in if condition
Date: Tue,  4 Nov 2014 22:54:36 +0100
Message-ID: <1415138076-7036-1-git-send-email-fabf@skynet.be>
Cc: Joe Perches <joe@perches.com>, Fabian Frederick <fabf@skynet.be>,
	Steffen Klassert <steffen.klassert@secunet.com>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	"David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>, netdev@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Fabian Frederick <fabf@skynet.be>
---
V2: remove blank line between set and test (suggested by Joe Perches).

 net/ipv4/esp4.c | 4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

diff --git a/net/ipv4/esp4.c b/net/ipv4/esp4.c
index 360b565..d2bf02e 100644
--- a/net/ipv4/esp4.c
+++ b/net/ipv4/esp4.c
@@ -392,8 +392,10 @@ static int esp_input(struct xfrm_state *x, struct sk_buff *skb)
 	if (elen <= 0)
 		goto out;
 
-	if ((err = skb_cow_data(skb, 0, &trailer)) < 0)
+	err = skb_cow_data(skb, 0, &trailer);
+	if (err < 0)
 		goto out;
+
 	nfrags = err;
 
 	assoclen = sizeof(*esph);
-- 
1.9.3
