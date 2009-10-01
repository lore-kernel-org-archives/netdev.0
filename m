From: Yevgeny Petrilin <yevgenyp@mellanox.co.il>
Subject: [PATCH 3/7] mlx4: Added HW_HEALTH_CHECK command opcode
Date: Thu, 01 Oct 2009 16:33:40 +0200
Message-ID: <4AC4BDC4.6090509@mellanox.co.il>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.mellanox.co.il ([194.90.237.43]:60208 "EHLO mellanox.co.il"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1756410AbZJALf1 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 1 Oct 2009 07:35:27 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When the command is executed, the Firmware checks HW state and configuration
registers and returns status.

Signed-off-by: Yevgeny Petrilin <yevgenyp@mellanox.co.il>
---
 include/linux/mlx4/cmd.h |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/include/linux/mlx4/cmd.h b/include/linux/mlx4/cmd.h
index 0f82293..78a1b96 100644
--- a/include/linux/mlx4/cmd.h
+++ b/include/linux/mlx4/cmd.h
@@ -56,6 +56,7 @@ enum {
 	MLX4_CMD_QUERY_HCA	 = 0xb,
 	MLX4_CMD_QUERY_PORT	 = 0x43,
 	MLX4_CMD_SENSE_PORT	 = 0x4d,
+	MLX4_CMD_HW_HEALTH_CHECK = 0x50,
 	MLX4_CMD_SET_PORT	 = 0xc,
 	MLX4_CMD_ACCESS_DDR	 = 0x2e,
 	MLX4_CMD_MAP_ICM	 = 0xffa,
-- 
1.6.1.3

