From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 02/15] mlxsw: switchx2: Use ETH_ALEN for mac address length
Date: Thu, 15 Oct 2015 17:43:16 +0200
Message-ID: <1444923809-20785-3-git-send-email-jiri@resnulli.us>
References: <1444923809-20785-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, eladr@mellanox.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f181.google.com ([209.85.217.181]:36541 "EHLO
	mail-lb0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753593AbbJOPng (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 Oct 2015 11:43:36 -0400
Received: by lbcao8 with SMTP id ao8so73577372lbc.3
        for <netdev@vger.kernel.org>; Thu, 15 Oct 2015 08:43:34 -0700 (PDT)
In-Reply-To: <1444923809-20785-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@mellanox.com>

Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlxsw/switchx2.c | 4 +---
 1 file changed, 1 insertion(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlxsw/switchx2.c b/drivers/net/ethernet/mellanox/mlxsw/switchx2.c
index 4dadc46..fd6f438 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/switchx2.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/switchx2.c
@@ -57,13 +57,11 @@ static const char mlxsw_sx_driver_version[] = "1.0";
 
 struct mlxsw_sx_port;
 
-#define MLXSW_SW_HW_ID_LEN 6
-
 struct mlxsw_sx {
 	struct mlxsw_sx_port **ports;
 	struct mlxsw_core *core;
 	const struct mlxsw_bus_info *bus_info;
-	u8 hw_id[MLXSW_SW_HW_ID_LEN];
+	u8 hw_id[ETH_ALEN];
 };
 
 struct mlxsw_sx_port_pcpu_stats {
-- 
1.9.3
