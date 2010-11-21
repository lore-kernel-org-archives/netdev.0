From: Joe Perches <joe@perches.com>
Subject: [PATCH 39/62] skfp: Use static const
Date: Sat, 20 Nov 2010 18:38:40 -0800
Message-ID: <4299363b58d9bbc9ef41045053980c0f5818cedd.1290305776.git.joe@perches.com>
References: <cover.1290305773.git.joe@perches.com>
Cc: linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <cover.1290305773.git.joe@perches.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Using static const generally increases object text and decreases data size.
It also generally decreases overall object size.

   text	   data	    bss	    dec	    hex	filename
  13874	     56	   2560	  16490	   406a	drivers/net/skfp/smt.o.new
  13858	     72	   2560	  16490	   406a	drivers/net/skfp/smt.o.old

Signed-off-by: Joe Perches <joe@perches.com>
---
 drivers/net/skfp/smt.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/skfp/smt.c b/drivers/net/skfp/smt.c
index 2d9941c..1e1bd0c 100644
--- a/drivers/net/skfp/smt.c
+++ b/drivers/net/skfp/smt.c
@@ -1263,7 +1263,7 @@ void smt_set_timestamp(struct s_smc *smc, u_char *p)
 static void smt_fill_policy(struct s_smc *smc, struct smt_p_policy *policy)
 {
 	int	i ;
-	u_char	*map ;
+	const u_char *map ;
 	u_short	in ;
 	u_short	out ;
 
@@ -1271,7 +1271,7 @@ static void smt_fill_policy(struct s_smc *smc, struct smt_p_policy *policy)
 	 * MIB para 101b (fddiSMTConnectionPolicy) coding
 	 * is different from 0005 coding
 	 */
-	static u_char	ansi_weirdness[16] = {
+	static const u_char ansi_weirdness[16] = {
 		0,7,5,3,8,1,6,4,9,10,2,11,12,13,14,15
 	} ;
 	SMTSETPARA(policy,SMT_P_POLICY) ;
-- 
1.7.3.2.245.g03276.dirty
