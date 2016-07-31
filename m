From: Heinrich Schuchardt <xypron.glpk@gmx.de>
Subject: [PATCH 1/1] net: qlge: remove superfluous statement
Date: Sun, 31 Jul 2016 12:19:28 +0200
Message-ID: <1469960368-1616-1-git-send-email-xypron.glpk@gmx.de>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Heinrich Schuchardt <xypron.glpk@gmx.de>
To: Harish Patil <harish.patil@qlogic.com>,
	Sudarsana Kalluru <sudarsana.kalluru@qlogic.com>,
	Dept-GELinuxNICDev@qlogic.com, linux-driver@qlogic.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout.gmx.net ([212.227.15.15]:50181 "EHLO mout.gmx.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751338AbcGaKTj (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 31 Jul 2016 06:19:39 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Variable length is not used after the deleted line.

Signed-off-by: Heinrich Schuchardt <xypron.glpk@gmx.de>
---
 drivers/net/ethernet/qlogic/qlge/qlge_main.c | 1 -
 1 file changed, 1 deletion(-)

diff --git a/drivers/net/ethernet/qlogic/qlge/qlge_main.c b/drivers/net/ethernet/qlogic/qlge/qlge_main.c
index fd5d1c9..fd4a8e4 100644
--- a/drivers/net/ethernet/qlogic/qlge/qlge_main.c
+++ b/drivers/net/ethernet/qlogic/qlge/qlge_main.c
@@ -1892,7 +1892,6 @@ static struct sk_buff *ql_build_rx_skb(struct ql_adapter *qdev,
 			skb->len += length;
 			skb->data_len += length;
 			skb->truesize += length;
-			length -= length;
 			ql_update_mac_hdr_len(qdev, ib_mac_rsp,
 					      lbq_desc->p.pg_chunk.va,
 					      &hlen);
-- 
2.8.1
