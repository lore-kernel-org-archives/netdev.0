From: Colin King <colin.king@canonical.com>
Subject: [PATCH] fsl/fman: fix spelling mistake in variable name en_tsu_err_exeption
Date: Sat, 18 Feb 2017 23:41:46 +0000
Message-ID: <20170218234146.20041-1-colin.king@canonical.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit
Cc: kernel-janitors@vger.kernel.org, linux-kernel@vger.kernel.org
To: Madalin Bucur <madalin.bucur@nxp.com>, netdev@vger.kernel.org
Return-path: <kernel-janitors-owner@vger.kernel.org>
Sender: kernel-janitors-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Colin Ian King <colin.king@canonical.com>

trivial fix to spelling mistake, en_tsu_err_exeption should
be en_tsu_err_exception

Signed-off-by: Colin Ian King <colin.king@canonical.com>
---
 drivers/net/ethernet/freescale/fman/fman_dtsec.c | 8 ++++----
 1 file changed, 4 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/freescale/fman/fman_dtsec.c b/drivers/net/ethernet/freescale/fman/fman_dtsec.c
index c88918c..84ea130 100644
--- a/drivers/net/ethernet/freescale/fman/fman_dtsec.c
+++ b/drivers/net/ethernet/freescale/fman/fman_dtsec.c
@@ -337,7 +337,7 @@ struct fman_mac {
 	u8 mac_id;
 	u32 exceptions;
 	bool ptp_tsu_enabled;
-	bool en_tsu_err_exeption;
+	bool en_tsu_err_exception;
 	struct dtsec_cfg *dtsec_drv_param;
 	void *fm;
 	struct fman_rev_info fm_rev_info;
@@ -1247,12 +1247,12 @@ int dtsec_set_exception(struct fman_mac *dtsec,
 		switch (exception) {
 		case FM_MAC_EX_1G_1588_TS_RX_ERR:
 			if (enable) {
-				dtsec->en_tsu_err_exeption = true;
+				dtsec->en_tsu_err_exception = true;
 				iowrite32be(ioread32be(&regs->tmr_pemask) |
 					    TMR_PEMASK_TSREEN,
 					    &regs->tmr_pemask);
 			} else {
-				dtsec->en_tsu_err_exeption = false;
+				dtsec->en_tsu_err_exception = false;
 				iowrite32be(ioread32be(&regs->tmr_pemask) &
 					    ~TMR_PEMASK_TSREEN,
 					    &regs->tmr_pemask);
@@ -1420,7 +1420,7 @@ struct fman_mac *dtsec_config(struct fman_mac_params *params)
 	dtsec->event_cb = params->event_cb;
 	dtsec->dev_id = params->dev_id;
 	dtsec->ptp_tsu_enabled = dtsec->dtsec_drv_param->ptp_tsu_en;
-	dtsec->en_tsu_err_exeption = dtsec->dtsec_drv_param->ptp_exception_en;
+	dtsec->en_tsu_err_exception = dtsec->dtsec_drv_param->ptp_exception_en;
 
 	dtsec->fm = params->fm;
 	dtsec->basex_if = params->basex_if;
-- 
2.10.2

