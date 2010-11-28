From: Joe Perches <joe@perches.com>
Subject: [PATCH 2/4] qlcnic: remove unnecessary [kv][mcz]alloc casts
Date: Sun, 28 Nov 2010 01:05:44 -0800
Message-ID: <09e14a8c16d54605ab6d3be562abc6820ba2a7aa.1290934782.git.joe@perches.com>
References: <cover.1290934782.git.joe@perches.com>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Amit Kumar Salecha <amit.salecha@qlogic.com>,
	Anirban Chakraborty <anirban.chakraborty@qlogic.com>,
	linux-driver@qlogic.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.perches.com ([173.55.12.10]:1889 "EHLO mail.perches.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751982Ab0K1JFw (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 28 Nov 2010 04:05:52 -0500
In-Reply-To: <cover.1290934782.git.joe@perches.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Joe Perches <joe@perches.com>
---
 drivers/net/qlcnic/qlcnic_init.c |    3 +--
 1 files changed, 1 insertions(+), 2 deletions(-)

diff --git a/drivers/net/qlcnic/qlcnic_init.c b/drivers/net/qlcnic/qlcnic_init.c
index 3f97018..c5ea2f4 100644
--- a/drivers/net/qlcnic/qlcnic_init.c
+++ b/drivers/net/qlcnic/qlcnic_init.c
@@ -274,8 +274,7 @@ int qlcnic_alloc_sw_resources(struct qlcnic_adapter *adapter)
 				rds_ring->dma_size + NET_IP_ALIGN;
 			break;
 		}
-		rds_ring->rx_buf_arr = (struct qlcnic_rx_buffer *)
-			vzalloc(RCV_BUFF_RINGSIZE(rds_ring));
+		rds_ring->rx_buf_arr = vzalloc(RCV_BUFF_RINGSIZE(rds_ring));
 		if (rds_ring->rx_buf_arr == NULL) {
 			dev_err(&netdev->dev, "Failed to allocate "
 				"rx buffer ring %d\n", ring);
-- 
1.7.3.2.245.g03276.dirty

