From: Colin King <colin.king@canonical.com>
Subject: [PATCH] fddi: print an address with %p format specifier rather than %x
Date: Fri,  5 Jun 2015 19:19:11 +0100
Message-ID: <1433528351-31778-1-git-send-email-colin.king@canonical.com>
Cc: linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Colin Ian King <colin.king@canonical.com>

The debug is printing the struct smt_header * address using
the %x format specifier. Fix it to use %p instead.

Signed-off-by: Colin Ian King <colin.king@canonical.com>
---
 drivers/net/fddi/skfp/srf.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/fddi/skfp/srf.c b/drivers/net/fddi/skfp/srf.c
index cc27dea..9956680 100644
--- a/drivers/net/fddi/skfp/srf.c
+++ b/drivers/net/fddi/skfp/srf.c
@@ -414,7 +414,7 @@ static void smt_send_srf(struct s_smc *smc)
 	smt->smt_len = SMT_MAX_INFO_LEN - pcon.pc_len ;
 	mb->sm_len = smt->smt_len + sizeof(struct smt_header) ;
 
-	DB_SMT("SRF: sending SRF at %x, len %d\n",smt,mb->sm_len) ;
+	DB_SMT("SRF: sending SRF at %p, len %d\n",smt,mb->sm_len) ;
 	DB_SMT("SRF: state SR%d Threshold %d\n",
 		smc->srf.sr_state,smc->srf.SRThreshold/TICKS_PER_SECOND) ;
 #ifdef	DEBUG
-- 
2.1.4
