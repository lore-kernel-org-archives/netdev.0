From: Rickard Strandqvist <rickard_strandqvist@spectrumdigital.se>
Subject: [PATCH] net: ethernet: chelsio: cxgb3: mc5.c:  Remove some unused functions
Date: Thu,  1 Jan 2015 17:49:55 +0100
Message-ID: <1420130996-29910-1-git-send-email-rickard_strandqvist@spectrumdigital.se>
Cc: Rickard Strandqvist <rickard_strandqvist@spectrumdigital.se>,
	linux-kernel@vger.kernel.org
To: Santosh Raspatur <santosh@chelsio.com>, netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Removes some functions that are not used anywhere:
dbgi_rd_rsp3() dbgi_wr_addr3()

This was partially found by using a static code analysis program called cppcheck.

Signed-off-by: Rickard Strandqvist <rickard_strandqvist@spectrumdigital.se>
---
 drivers/net/ethernet/chelsio/cxgb3/mc5.c |   16 ----------------
 1 file changed, 16 deletions(-)

diff --git a/drivers/net/ethernet/chelsio/cxgb3/mc5.c b/drivers/net/ethernet/chelsio/cxgb3/mc5.c
index e13b7fe..338301b 100644
--- a/drivers/net/ethernet/chelsio/cxgb3/mc5.c
+++ b/drivers/net/ethernet/chelsio/cxgb3/mc5.c
@@ -97,14 +97,6 @@ static int mc5_cmd_write(struct adapter *adapter, u32 cmd)
 			       F_DBGIRSPVALID, 1, MAX_WRITE_ATTEMPTS, 1);
 }
 
-static inline void dbgi_wr_addr3(struct adapter *adapter, u32 v1, u32 v2,
-				 u32 v3)
-{
-	t3_write_reg(adapter, A_MC5_DB_DBGI_REQ_ADDR0, v1);
-	t3_write_reg(adapter, A_MC5_DB_DBGI_REQ_ADDR1, v2);
-	t3_write_reg(adapter, A_MC5_DB_DBGI_REQ_ADDR2, v3);
-}
-
 static inline void dbgi_wr_data3(struct adapter *adapter, u32 v1, u32 v2,
 				 u32 v3)
 {
@@ -113,14 +105,6 @@ static inline void dbgi_wr_data3(struct adapter *adapter, u32 v1, u32 v2,
 	t3_write_reg(adapter, A_MC5_DB_DBGI_REQ_DATA2, v3);
 }
 
-static inline void dbgi_rd_rsp3(struct adapter *adapter, u32 *v1, u32 *v2,
-				u32 *v3)
-{
-	*v1 = t3_read_reg(adapter, A_MC5_DB_DBGI_RSP_DATA0);
-	*v2 = t3_read_reg(adapter, A_MC5_DB_DBGI_RSP_DATA1);
-	*v3 = t3_read_reg(adapter, A_MC5_DB_DBGI_RSP_DATA2);
-}
-
 /*
  * Write data to the TCAM register at address (0, 0, addr_lo) using the TCAM
  * command cmd.  The data to be written must have been set up by the caller.
-- 
1.7.10.4
