From: Rickard Strandqvist <rickard_strandqvist@spectrumdigital.se>
Subject: [PATCH] net: ethernet: chelsio: cxgb4: t4_hw.c:  Cleaning up uninitialized variables
Date: Sun,  1 Jun 2014 14:34:15 +0200
Message-ID: <1401626055-15144-1-git-send-email-rickard_strandqvist@spectrumdigital.se>
Cc: Rickard Strandqvist <rickard_strandqvist@spectrumdigital.se>,
	linux-kernel@vger.kernel.org
To: Dimitris Michailidis <dm@chelsio.com>, netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

There is a risk that the variable will be used without being initialized.

This was largely found by using a static code analysis program called cppcheck.

Signed-off-by: Rickard Strandqvist <rickard_strandqvist@spectrumdigital.se>
---
 drivers/net/ethernet/chelsio/cxgb4/t4_hw.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/chelsio/cxgb4/t4_hw.c b/drivers/net/ethernet/chelsio/cxgb4/t4_hw.c
index bba6768..326c005 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/t4_hw.c
+++ b/drivers/net/ethernet/chelsio/cxgb4/t4_hw.c
@@ -571,7 +571,7 @@ int t4_seeprom_wp(struct adapter *adapter, bool enable)
  */
 int get_vpd_params(struct adapter *adapter, struct vpd_params *p)
 {
-	u32 cclk_param, cclk_val;
+	u32 cclk_param, cclk_val = 0;
 	int i, ret, addr;
 	int ec, sn, pn;
 	u8 *vpd, csum;
-- 
1.7.10.4
