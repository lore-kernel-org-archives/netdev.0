From: Julia Lawall <julia@diku.dk>
Subject: [PATCH] drivres/net: Change constant name
Date: Sat, 8 Aug 2009 09:53:41 +0200 (CEST)
Message-ID: <Pine.LNX.4.64.0908080953090.25176@ask.diku.dk>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
To: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	kernel-janitors@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S933690AbZHHHxo@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Julia Lawall <julia@diku.dk>

In this series of tests the constants have the form XRXMAC_STATUS, except
in this one case.  The values of XRXMAC_STAT_MSK_RXOCTET_CNT_EXP and
XRXMAC_STATUS_RXOCTET_CNT_EXP are furthermore the same.

Signed-off-by: Julia Lawall <julia@diku.dk>

---
 drivers/net/niu.c                   |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/niu.c b/drivers/net/niu.c
index d2146d4..3ada7ea 100644
--- a/drivers/net/niu.c
+++ b/drivers/net/niu.c
@@ -4015,7 +4015,7 @@ static void niu_xmac_interrupt(struct niu *np)
 		mp->rx_hist_cnt6 += RXMAC_HIST_CNT6_COUNT;
 	if (val & XRXMAC_STATUS_RXHIST7_CNT_EXP)
 		mp->rx_hist_cnt7 += RXMAC_HIST_CNT7_COUNT;
-	if (val & XRXMAC_STAT_MSK_RXOCTET_CNT_EXP)
+	if (val & XRXMAC_STATUS_RXOCTET_CNT_EXP)
 		mp->rx_octets += RXMAC_BT_CNT_COUNT;
 	if (val & XRXMAC_STATUS_CVIOLERR_CNT_EXP)
 		mp->rx_code_violations += RXMAC_CD_VIO_CNT_COUNT;
