From: Adrian-Ken Rueegsegger <rueegsegger@swiss-it.ch>
Subject: [RFC PATCH] [XFRM] xfrm_algo: correct usage of RIPEMD-160
Date: Mon,  2 Jun 2008 11:33:09 +0200
Message-ID: <12123991893044-git-send-email-rueegsegger@swiss-it.ch>
References: <1212399189188-git-send-email-rueegsegger@swiss-it.ch>
Cc: herbert@gondor.apana.org.au, netdev@vger.kernel.org,
	linux-crypto@vger.kernel.org,
	Adrian-Ken Rueegsegger <rueegsegger@swiss-it.ch>
To: davem@davemloft.net
Return-path: <linux-crypto-owner@vger.kernel.org>
In-Reply-To: <1212399189188-git-send-email-rueegsegger@swiss-it.ch>
Sender: linux-crypto-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch fixes the usage of RIPEMD-160 in xfrm_algo which in turn
allows hmac(rmd160) to be used as authentication mechanism in IPsec
ESP and AH (see RFC 2857).

Signed-off-by: Adrian-Ken Rueegsegger <rueegsegger@swiss-it.ch>
---
 net/xfrm/xfrm_algo.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/xfrm/xfrm_algo.c b/net/xfrm/xfrm_algo.c
index ac765dd..23a2cc0 100644
--- a/net/xfrm/xfrm_algo.c
+++ b/net/xfrm/xfrm_algo.c
@@ -200,8 +200,8 @@ static struct xfrm_algo_desc aalg_list[] = {
 	}
 },
 {
-	.name = "hmac(ripemd160)",
-	.compat = "ripemd160",
+	.name = "hmac(rmd160)",
+	.compat = "rmd160",
 
 	.uinfo = {
 		.auth = {
-- 
1.5.2.5

