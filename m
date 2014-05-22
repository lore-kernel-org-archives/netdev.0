From: Horia Geanta <horia.geanta@freescale.com>
Subject: [RFC ipsec-next] xfrm: make sha256 icv truncation length RFC-compliant
Date: Thu, 22 May 2014 18:10:37 +0300
Message-ID: <1400771437-14096-2-git-send-email-horia.geanta@freescale.com>
References: <1400771437-14096-1-git-send-email-horia.geanta@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Lei Xu <Lei.Xu@freescale.com>,
	Sandeep Malik <Sandeep.Malik@freescale.com>,
	<netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>
To: Steffen Klassert <steffen.klassert@secunet.com>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1400771437-14096-1-git-send-email-horia.geanta@freescale.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Lei Xu <Lei.Xu@freescale.com>

Currently the sha256 icv truncation length is set to 96bit
while the length is defined as 128bit in RFC4868.
This may result in somer errors when working with other IPsec devices
with the standard truncation length.
Thus, change the sha256 truncation length from 96bit to 128bit.

Signed-off-by: Lei Xu <Lei.Xu@freescale.com>
Signed-off-by: Horia Geanta <horia.geanta@freescale.com>
---
 net/xfrm/xfrm_algo.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/xfrm/xfrm_algo.c b/net/xfrm/xfrm_algo.c
index debe733386f8..ca21ba7a0716 100644
--- a/net/xfrm/xfrm_algo.c
+++ b/net/xfrm/xfrm_algo.c
@@ -220,7 +220,7 @@ static struct xfrm_algo_desc aalg_list[] = {
 
 	.uinfo = {
 		.auth = {
-			.icv_truncbits = 96,
+			.icv_truncbits = 128,
 			.icv_fullbits = 256,
 		}
 	},
-- 
1.8.3.1
