From: Calvin Owens <jcalvinowens@gmail.com>
Subject: [PATCH 1/1] xfrm: Apply commit 4203223a1aed862b4445fdcd260d6139603a51d9 to 2.6.32 stable series
Date: Tue,  6 Dec 2011 22:37:13 -0600
Message-ID: <1323232633-4307-1-git-send-email-jcalvinowens@gmail.com>
Cc: "David S. Miller" <davem@davemloft.net>,
	Calvin Owens <jcalvinowens@gmail.com>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: stable@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Calvin Owens <calvinow@Beethoven.(none)>

This fix was applied to 3.0.3, but was not applied to earlier series. Distros based
on this (Debian Squeeze, among others) likely haven't got it in, which prevents
AES-CTR from being used for IPsec.

Signed-off-by: Calvin Owens <jcalvinowens@gmail.com>
Signed-off-by: Calvin Owens <calvinow@Beethoven.(none)>
---
 net/xfrm/xfrm_algo.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/xfrm/xfrm_algo.c b/net/xfrm/xfrm_algo.c
index faf54c6..9bd850a 100644
--- a/net/xfrm/xfrm_algo.c
+++ b/net/xfrm/xfrm_algo.c
@@ -411,8 +411,8 @@ static struct xfrm_algo_desc ealg_list[] = {
 	.desc = {
 		.sadb_alg_id = SADB_X_EALG_AESCTR,
 		.sadb_alg_ivlen	= 8,
-		.sadb_alg_minbits = 128,
-		.sadb_alg_maxbits = 256
+		.sadb_alg_minbits = 160,
+		.sadb_alg_maxbits = 288
 	}
 },
 };
-- 
1.7.4.1
