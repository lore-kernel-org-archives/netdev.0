From: Sudarsana Reddy Kalluru <sudarsana.kalluru@qlogic.com>
Subject: [PATCH net-next 1/1] Remove the redundant initialization statement.
Date: Mon, 13 Jun 2016 05:01:10 -0400
Message-ID: <1465808470-27424-1-git-send-email-sudarsana.kalluru@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <Yuval.Mintz@qlogic.com>,
	<sudarsana.kalluru@qlogic.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-0016ce01.pphosted.com ([67.231.156.153]:11771 "EHLO
	mx0b-0016ce01.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S964840AbcFMJpG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 13 Jun 2016 05:45:06 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The callback ".getcbx" is being initialized twice. This was introduced by
the commit 0fdeb72aa6c9 ("qede: Add dcbnl support."). The patch removes the
redundant initialization statement.

Reported-by: Julia Lawall <julia.lawall@lip6.fr> 
Signed-off-by: Yuval Mintz <Yuval.Mintz@qlogic.com>
Signed-off-by: Sudarsana Reddy Kalluru <sudarsana.kalluru@qlogic.com>
---
 drivers/net/ethernet/qlogic/qede/qede_dcbnl.c | 1 -
 1 file changed, 1 deletion(-)

diff --git a/drivers/net/ethernet/qlogic/qede/qede_dcbnl.c b/drivers/net/ethernet/qlogic/qede/qede_dcbnl.c
index 03e8c02..318f0cb 100644
--- a/drivers/net/ethernet/qlogic/qede/qede_dcbnl.c
+++ b/drivers/net/ethernet/qlogic/qede/qede_dcbnl.c
@@ -308,7 +308,6 @@ static const struct dcbnl_rtnl_ops qede_dcbnl_ops = {
 	.ieee_setets = qede_dcbnl_ieee_setets,
 	.ieee_getapp = qede_dcbnl_ieee_getapp,
 	.ieee_setapp = qede_dcbnl_ieee_setapp,
-	.getdcbx = qede_dcbnl_getdcbx,
 	.ieee_peer_getpfc = qede_dcbnl_ieee_peer_getpfc,
 	.ieee_peer_getets = qede_dcbnl_ieee_peer_getets,
 	.getstate = qede_dcbnl_getstate,
-- 
1.8.3.1
