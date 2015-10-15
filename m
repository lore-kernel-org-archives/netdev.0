From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 11/15] mlxsw: reg: Adjust definition of enum mlxsw_reg_sfgc_type
Date: Thu, 15 Oct 2015 17:43:25 +0200
Message-ID: <1444923809-20785-12-git-send-email-jiri@resnulli.us>
References: <1444923809-20785-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, eladr@mellanox.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f175.google.com ([209.85.220.175]:35780 "EHLO
	mail-qk0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753736AbbJOPnp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 Oct 2015 11:43:45 -0400
Received: by qkap81 with SMTP id p81so40796526qka.2
        for <netdev@vger.kernel.org>; Thu, 15 Oct 2015 08:43:44 -0700 (PDT)
In-Reply-To: <1444923809-20785-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ido Schimmel <idosch@mellanox.com>

Define max which would be needed later on.

Signed-off-by: Ido Schimmel <idosch@mellanox.com>
Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlxsw/reg.h | 16 +++++++++-------
 1 file changed, 9 insertions(+), 7 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlxsw/reg.h b/drivers/net/ethernet/mellanox/mlxsw/reg.h
index 34b95a1..6fca13a 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/reg.h
+++ b/drivers/net/ethernet/mellanox/mlxsw/reg.h
@@ -214,13 +214,15 @@ static const struct mlxsw_reg_info mlxsw_reg_sfgc = {
 };
 
 enum mlxsw_reg_sfgc_type {
-	MLXSW_REG_SFGC_TYPE_BROADCAST = 0,
-	MLXSW_REG_SFGC_TYPE_UNKNOWN_UNICAST = 1,
-	MLXSW_REG_SFGC_TYPE_UNREGISTERED_MULTICAST_IPV4 = 2,
-	MLXSW_REG_SFGC_TYPE_UNREGISTERED_MULTICAST_IPV6 = 3,
-	MLXSW_REG_SFGC_TYPE_UNREGISTERED_MULTICAST_NON_IP = 5,
-	MLXSW_REG_SFGC_TYPE_IPV4_LINK_LOCAL = 6,
-	MLXSW_REG_SFGC_TYPE_IPV6_ALL_HOST = 7,
+	MLXSW_REG_SFGC_TYPE_BROADCAST,
+	MLXSW_REG_SFGC_TYPE_UNKNOWN_UNICAST,
+	MLXSW_REG_SFGC_TYPE_UNREGISTERED_MULTICAST_IPV4,
+	MLXSW_REG_SFGC_TYPE_UNREGISTERED_MULTICAST_IPV6,
+	MLXSW_REG_SFGC_TYPE_RESERVED,
+	MLXSW_REG_SFGC_TYPE_UNREGISTERED_MULTICAST_NON_IP,
+	MLXSW_REG_SFGC_TYPE_IPV4_LINK_LOCAL,
+	MLXSW_REG_SFGC_TYPE_IPV6_ALL_HOST,
+	MLXSW_REG_SFGC_TYPE_MAX,
 };
 
 /* reg_sfgc_type
-- 
1.9.3
