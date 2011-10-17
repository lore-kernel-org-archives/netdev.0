From: Yevgeny Petrilin <yevgenyp@mellanox.co.il>
Subject: [PATCH 5/7] mlx4_en: Recording rx queue for gro packets
Date: Mon, 17 Oct 2011 22:18:04 +0200
Message-ID: <4E9C8D7C.2040306@mellanox.co.il>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <yevgenyp@mellanox.co.il>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog114.obsmtp.com ([207.126.144.137]:44327 "HELO
	eu1sys200aog114.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1754371Ab1JQWYU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 17 Oct 2011 18:24:20 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Signed-off-by: Yevgeny Petrilin <yevgenyp@mellanox.co.il>
---
 drivers/net/ethernet/mellanox/mlx4/en_rx.c |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx4/en_rx.c b/drivers/net/ethernet/mellanox/mlx4/en_rx.c
index 45b1a3d..f42c7a6 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_rx.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_rx.c
@@ -618,6 +618,7 @@ int mlx4_en_process_rx_cq(struct net_device *dev, struct mlx4_en_cq *cq, int bud
 						__vlan_hwaccel_put_tag(gro_skb, vid);
 					}
 
+					skb_record_rx_queue(gro_skb, cq->ring);
 					napi_gro_frags(&cq->napi);
 
 					goto next;
-- 
1.7.7
