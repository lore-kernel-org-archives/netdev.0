From: Sanjeev Sharma <sanjeev_sharma@mentor.com>
Subject: [PATCH v3] gianfar: correct the bad expression while writing bit-pattern
Date: Tue, 3 Feb 2015 13:02:02 +0530
Message-ID: <1422948722-16864-1-git-send-email-sanjeev_sharma@mentor.com>
References: <54B3D899.5060204@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <davem@davemloft.net>, <matei.pavaluca@freescale.com>,
	<netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
	Sanjeev Sharma <sanjeev_sharma@mentor.com>,
	Sanjeev Sharma <Sanjeev_Sharma@mentor.com>
To: <claudiu.manoil@freescale.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay1.mentorg.com ([192.94.38.131]:47477 "EHLO
	relay1.mentorg.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753919AbbBCHcM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Feb 2015 02:32:12 -0500
In-Reply-To: <54B3D899.5060204@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch correct the bad expression while writing the
bit-pattern from software's buffer to hardware registers.

Signed-off-by: Sanjeev Sharma <Sanjeev_Sharma@mentor.com>
---
Changes in v3:
  - corrected the expression by introducing tab->fe[i].prop.

 drivers/net/ethernet/freescale/gianfar_ethtool.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/freescale/gianfar_ethtool.c b/drivers/net/ethernet/freescale/gianfar_ethtool.c
index 3e1a9c1..fda12fb 100644
--- a/drivers/net/ethernet/freescale/gianfar_ethtool.c
+++ b/drivers/net/ethernet/freescale/gianfar_ethtool.c
@@ -1586,7 +1586,7 @@ static int gfar_write_filer_table(struct gfar_private *priv,
 		return -EBUSY;
 
 	/* Fill regular entries */
-	for (; i < MAX_FILER_IDX - 1 && (tab->fe[i].ctrl | tab->fe[i].ctrl);
+	for (; i < MAX_FILER_IDX - 1 && (tab->fe[i].ctrl | tab->fe[i].prop);
 	     i++)
 		gfar_write_filer(priv, i, tab->fe[i].ctrl, tab->fe[i].prop);
 	/* Fill the rest with fall-troughs */
-- 
1.7.11.7
