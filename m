From: Hariprasad Shenai <hariprasad@chelsio.com>
Subject: [PATCH net-next] cxgb4/cxgb4vf: Add support for IFLA_VF_VLAN
Date: Sat, 20 Aug 2016 12:04:36 +0530
Message-ID: <1471674876-2833-1-git-send-email-hariprasad@chelsio.com>
Cc: davem@davemloft.net, leedom@chelsio.com, nirranjan@chelsio.com,
        Hariprasad Shenai <hariprasad@chelsio.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([12.32.117.8]:19548 "EHLO
        stargate3.asicdesigners.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S1751164AbcHTGaI (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 20 Aug 2016 02:30:08 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Adds support for ndo_set_vf_vlan for cxgb4 driver

Signed-off-by: Hariprasad Shenai <hariprasad@chelsio.com>
---
 drivers/net/ethernet/chelsio/cxgb4/cxgb4.h | 1 +
 1 file changed, 1 insertion(+)

diff --git a/drivers/net/ethernet/chelsio/cxgb4/cxgb4.h b/drivers/net/ethernet/chelsio/cxgb4/cxgb4.h
index 6b0528913687..f354f90d7faa 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/cxgb4.h
+++ b/drivers/net/ethernet/chelsio/cxgb4/cxgb4.h
@@ -1572,6 +1572,7 @@ void t4_idma_monitor(struct adapter *adapter,
 		     int hz, int ticks);
 int t4_set_vf_mac_acl(struct adapter *adapter, unsigned int vf,
 		      unsigned int naddr, u8 *addr);
+int t4_set_vf_vlan_acl(struct adapter *adapter, unsigned int vf, u16 vlan);
 void uld_mem_free(struct adapter *adap);
 int uld_mem_alloc(struct adapter *adap);
 void free_rspq_fl(struct adapter *adap, struct sge_rspq *rq, struct sge_fl *fl);
-- 
2.3.4
