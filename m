From: Calvin Owens <jcalvinowens@gmail.com>
Subject: [PATCH] xfrm: Apply fix for key lengths for rfc3686(ctr(aes)) to
 2.6.32.y
Date: Fri, 09 Dec 2011 14:29:06 -0600
Message-ID: <1323462546.2808.8.camel@Beethoven>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, Greg Kroah-Hartman <gregkh@suse.de>,
	Calvin Owens <jcalvinowens@gmail.com>
To: stable@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This fix was applied to 3.0.3, but was not applied to the earlier series. Several
widely-used distros base (or based) their kernels on this series, so the problem
hasn't been fixed for them. The patch below is against 2.6.32.49.

Original commit was 4203223a1aed862b4445fdcd260d6139603a51d9

Signed-off-by: Calvin Owens <jcalvinowens@gmail.com>
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
