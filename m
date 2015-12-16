From: Hariprasad Shenai <hariprasad@chelsio.com>
Subject: [PATCH net-next 1/4] cxgb4: Use mask & shift while returning vlan_prio
Date: Wed, 16 Dec 2015 13:16:25 +0530
Message-ID: <1450251988-9246-2-git-send-email-hariprasad@chelsio.com>
References: <1450251988-9246-1-git-send-email-hariprasad@chelsio.com>
Cc: davem@davemloft.net, leedom@chelsio.com, nirranjan@chelsio.com,
	Hariprasad Shenai <hariprasad@chelsio.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([12.32.117.8]:41797 "EHLO
	stargate3.asicdesigners.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S932681AbbLPHpV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Dec 2015 02:45:21 -0500
In-Reply-To: <1450251988-9246-1-git-send-email-hariprasad@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Hariprasad Shenai <hariprasad@chelsio.com>
---
 drivers/net/ethernet/chelsio/cxgb4/l2t.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/chelsio/cxgb4/l2t.c b/drivers/net/ethernet/chelsio/cxgb4/l2t.c
index ac27898..aa5fbad 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/l2t.c
+++ b/drivers/net/ethernet/chelsio/cxgb4/l2t.c
@@ -66,7 +66,7 @@ struct l2t_data {
 
 static inline unsigned int vlan_prio(const struct l2t_entry *e)
 {
-	return e->vlan >> 13;
+	return (e->vlan & VLAN_PRIO_MASK) >> VLAN_PRIO_SHIFT;
 }
 
 static inline void l2t_hold(struct l2t_data *d, struct l2t_entry *e)
-- 
2.3.4
