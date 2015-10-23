From: Claudiu Manoil <claudiu.manoil@freescale.com>
Subject: [PATCH net 1/4] gianfar: Remove duplicated argument to bitwise OR
Date: Fri, 23 Oct 2015 11:41:58 +0300
Message-ID: <1445589721-26206-2-git-send-email-claudiu.manoil@freescale.com>
References: <1445589721-26206-1-git-send-email-claudiu.manoil@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain
To: "David S. Miller" <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-by2on0148.outbound.protection.outlook.com ([207.46.100.148]:61376
	"EHLO na01-by2-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751666AbbJWImS (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 23 Oct 2015 04:42:18 -0400
In-Reply-To: <1445589721-26206-1-git-send-email-claudiu.manoil@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

RQFCR_AND is duplicated.
Add missing space as well.

Signed-off-by: Claudiu Manoil <claudiu.manoil@freescale.com>
---
 drivers/net/ethernet/freescale/gianfar_ethtool.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/freescale/gianfar_ethtool.c b/drivers/net/ethernet/freescale/gianfar_ethtool.c
index 6bdc891..a33e4a8 100644
--- a/drivers/net/ethernet/freescale/gianfar_ethtool.c
+++ b/drivers/net/ethernet/freescale/gianfar_ethtool.c
@@ -676,14 +676,14 @@ static void ethflow_to_filer_rules (struct gfar_private *priv, u64 ethflow)
 	u32 fcr = 0x0, fpr = FPR_FILER_MASK;
 
 	if (ethflow & RXH_L2DA) {
-		fcr = RQFCR_PID_DAH |RQFCR_CMP_NOMATCH |
+		fcr = RQFCR_PID_DAH | RQFCR_CMP_NOMATCH |
 		      RQFCR_HASH | RQFCR_AND | RQFCR_HASHTBL_0;
 		priv->ftp_rqfpr[priv->cur_filer_idx] = fpr;
 		priv->ftp_rqfcr[priv->cur_filer_idx] = fcr;
 		gfar_write_filer(priv, priv->cur_filer_idx, fcr, fpr);
 		priv->cur_filer_idx = priv->cur_filer_idx - 1;
 
-		fcr = RQFCR_PID_DAL | RQFCR_AND | RQFCR_CMP_NOMATCH |
+		fcr = RQFCR_PID_DAL | RQFCR_CMP_NOMATCH |
 		      RQFCR_HASH | RQFCR_AND | RQFCR_HASHTBL_0;
 		priv->ftp_rqfpr[priv->cur_filer_idx] = fpr;
 		priv->ftp_rqfcr[priv->cur_filer_idx] = fcr;
-- 
1.7.11.7
