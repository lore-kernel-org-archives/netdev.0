From: Yevgeny Petrilin <yevgenyp@mellanox.co.il>
Subject: [PATCH 05/14] mlx4_en: Fixed MAX_TX_RINGS definition
Date: Tue, 24 Aug 2010 16:45:54 +0300
Message-ID: <4C73CD12.1000005@mellanox.co.il>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <yevgenyp@mellanox.co.il>,
	<eugenia@mellanox.co.il>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.mellanox.co.il ([194.90.237.43]:50077 "EHLO mellanox.co.il"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1755238Ab0HXNp5 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 24 Aug 2010 09:45:57 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Defined as sum of default number of TX rings and number of
rings used for priority flow control mode.

Signed-off-by: Yevgeny Petrilin <yevgenyp@mellanox.co.il>
---
 drivers/net/mlx4/mlx4_en.h |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/mlx4/mlx4_en.h b/drivers/net/mlx4/mlx4_en.h
index 4492109..f8f3ad3 100644
--- a/drivers/net/mlx4/mlx4_en.h
+++ b/drivers/net/mlx4/mlx4_en.h
@@ -61,7 +61,6 @@
 
 #define MLX4_EN_PAGE_SHIFT	12
 #define MLX4_EN_PAGE_SIZE	(1 << MLX4_EN_PAGE_SHIFT)
-#define MAX_TX_RINGS		16
 #define MAX_RX_RINGS		16
 #define TXBB_SIZE		64
 #define HEADROOM		(2048 / TXBB_SIZE + 1)
@@ -107,6 +106,7 @@ enum {
 #define MLX4_EN_SMALL_PKT_SIZE		64
 #define MLX4_EN_NUM_TX_RINGS		8
 #define MLX4_EN_NUM_PPP_RINGS		8
+#define MAX_TX_RINGS			(MLX4_EN_NUM_TX_RINGS + MLX4_EN_NUM_PPP_RINGS)
 #define MLX4_EN_DEF_TX_RING_SIZE	512
 #define MLX4_EN_DEF_RX_RING_SIZE  	1024
 
-- 
1.6.1.3


