From: Yevgeny Petrilin <yevgenyp@mellanox.co.il>
Subject: [PATCH net-next 1/2] mlx4_core: using array index for sense_allowed
Date: Thu, 29 Dec 2011 19:42:34 +0200
Message-ID: <4EFCA68A.4010207@mellanox.co.il>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <yevgenyp@mellanox.co.il>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog120.obsmtp.com ([207.126.144.149]:48375 "HELO
	eu1sys200aog120.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1753662Ab1L2Rs5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 29 Dec 2011 12:48:57 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Signed-off-by: Yevgeny Petrilin <yevgenyp@mellanox.co.il>
---
 drivers/net/ethernet/mellanox/mlx4/main.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx4/main.c b/drivers/net/ethernet/mellanox/mlx4/main.c
index 1209934..6bb62c5 100644
--- a/drivers/net/ethernet/mellanox/mlx4/main.c
+++ b/drivers/net/ethernet/mellanox/mlx4/main.c
@@ -332,7 +332,7 @@ static int mlx4_dev_cap(struct mlx4_dev *dev, struct mlx4_dev_cap *dev_cap)
 		 * and perform sense_port FW command to try and set the correct
 		 * port type from beginning
 		 */
-		if (mlx4_priv(dev)->sense.sense_allowed && dev->caps.default_sense[i]) {
+		if (mlx4_priv(dev)->sense.sense_allowed[i] && dev->caps.default_sense[i]) {
 			enum mlx4_port_type sensed_port = MLX4_PORT_TYPE_NONE;
 			dev->caps.possible_type[i] = MLX4_PORT_TYPE_AUTO;
 			mlx4_SENSE_PORT(dev, i, &sensed_port);
-- 
1.7.7
