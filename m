From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 5/8] mlxsw: Changing the maximum number of multicast group to a define
Date: Sun, 10 Jan 2016 14:07:25 +0100
Message-ID: <1452431248-5411-6-git-send-email-jiri@resnulli.us>
References: <1452431248-5411-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, eladr@mellanox.com,
	yotamg@mellanox.com, ogerlitz@mellanox.com, corbet@lwn.net,
	stephen@networkplumber.org, sfeldma@gmail.com,
	vivien.didelot@savoirfairelinux.com, roopa@cumulusnetworks.com,
	gospo@cumulusnetworks.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f46.google.com ([74.125.82.46]:34480 "EHLO
	mail-wm0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756226AbcAJNHi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 10 Jan 2016 08:07:38 -0500
Received: by mail-wm0-f46.google.com with SMTP id u188so185303097wmu.1
        for <netdev@vger.kernel.org>; Sun, 10 Jan 2016 05:07:38 -0800 (PST)
In-Reply-To: <1452431248-5411-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Elad Raz <eladr@mellanox.com>

Signed-off-by: Elad Raz <eladr@mellanox.com>
Signed-off-by: Ido Schimmel <idosch@mellanox.com>
Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlxsw/spectrum.c | 2 +-
 drivers/net/ethernet/mellanox/mlxsw/spectrum.h | 2 ++
 2 files changed, 3 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum.c b/drivers/net/ethernet/mellanox/mlxsw/spectrum.c
index b6f3650..d0e98b8 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum.c
@@ -1939,7 +1939,7 @@ static struct mlxsw_config_profile mlxsw_sp_config_profile = {
 	.used_max_port_per_lag		= 1,
 	.max_port_per_lag		= MLXSW_SP_PORT_PER_LAG_MAX,
 	.used_max_mid			= 1,
-	.max_mid			= 7000,
+	.max_mid			= MLXSW_SP_MID_MAX,
 	.used_max_pgt			= 1,
 	.max_pgt			= 0,
 	.used_max_system_port		= 1,
diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum.h b/drivers/net/ethernet/mellanox/mlxsw/spectrum.h
index 0bbaef3..f360618 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum.h
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum.h
@@ -54,6 +54,8 @@
 #define MLXSW_SP_LAG_MAX 64
 #define MLXSW_SP_PORT_PER_LAG_MAX 16
 
+#define MLXSW_SP_MID_MAX 7000
+
 struct mlxsw_sp_port;
 
 struct mlxsw_sp_upper {
-- 
1.9.3
