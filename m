From: Anish Bhatt <anish@chelsio.com>
Subject: [PATCH net-next 3/4] cxgb4 : Fill in number of DCB traffic classes supported
Date: Fri, 17 Jul 2015 13:12:32 -0700
Message-ID: <1437163953-15447-4-git-send-email-anish@chelsio.com>
References: <1437163953-15447-1-git-send-email-anish@chelsio.com>
Cc: davem@davemloft.net, hariprasad@chelsio.com,
	Anish Bhatt <anish@chelsio.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([67.207.112.58]:20286 "EHLO
	stargate3.asicdesigners.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1752278AbbGQUMl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 17 Jul 2015 16:12:41 -0400
In-Reply-To: <1437163953-15447-1-git-send-email-anish@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Anish Bhatt <anish@chelsio.com>
---
 drivers/net/ethernet/chelsio/cxgb4/cxgb4_dcb.c | 4 ++++
 1 file changed, 4 insertions(+)

diff --git a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_dcb.c b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_dcb.c
index 56a81b8f7c54..052c660aca80 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_dcb.c
+++ b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_dcb.c
@@ -1193,6 +1193,8 @@ static int cxgb4_cee_peer_getpg(struct net_device *dev, struct cee_pg *pg)
 	for (i = 0; i < CXGB4_MAX_PRIORITY; i++)
 		pg->pg_bw[i] = pcmd.u.dcb.pgrate.pgrate[i];
 
+	pg->tcs_supported = pcmd.u.dcb.pgrate.num_tcs_supported;
+
 	return 0;
 }
 
@@ -1210,6 +1212,8 @@ static int cxgb4_cee_peer_getpfc(struct net_device *dev, struct cee_pfc *pfc)
 	 */
 	pfc->pfc_en = bitswap_1(pi->dcb.pfcen);
 
+	pfc->tcs_supported = pi->dcb.pfc_num_tcs_supported;
+
 	return 0;
 }
 
-- 
2.4.6
