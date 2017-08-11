From: Bhumika Goyal <bhumirks@gmail.com>
Subject: [PATCH] mlxsw: make mlxsw_config_profile const
Date: Fri, 11 Aug 2017 19:10:42 +0530
Message-ID: <1502458842-31516-1-git-send-email-bhumirks@gmail.com>
Cc: Bhumika Goyal <bhumirks@gmail.com>
To: julia.lawall@lip6.fr, jiri@mellanox.com, idosch@mellanox.com,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Make these structures const as they only stored in the profile field of
a mlxsw_driver structure, which is of type const.
Done using Coccinelle.

Signed-off-by: Bhumika Goyal <bhumirks@gmail.com>
---
 drivers/net/ethernet/mellanox/mlxsw/spectrum.c | 2 +-
 drivers/net/ethernet/mellanox/mlxsw/switchib.c | 2 +-
 drivers/net/ethernet/mellanox/mlxsw/switchx2.c | 2 +-
 3 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum.c b/drivers/net/ethernet/mellanox/mlxsw/spectrum.c
index eb7c454..82f8ccd 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum.c
@@ -3743,7 +3743,7 @@ static void mlxsw_sp_fini(struct mlxsw_core *mlxsw_core)
 	mlxsw_sp_fids_fini(mlxsw_sp);
 }
 
-static struct mlxsw_config_profile mlxsw_sp_config_profile = {
+static const struct mlxsw_config_profile mlxsw_sp_config_profile = {
 	.used_max_vepa_channels		= 1,
 	.max_vepa_channels		= 0,
 	.used_max_mid			= 1,
diff --git a/drivers/net/ethernet/mellanox/mlxsw/switchib.c b/drivers/net/ethernet/mellanox/mlxsw/switchib.c
index 74341fe..ab7a298 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/switchib.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/switchib.c
@@ -497,7 +497,7 @@ static void mlxsw_sib_fini(struct mlxsw_core *mlxsw_core)
 	mlxsw_sib_ports_remove(mlxsw_sib);
 }
 
-static struct mlxsw_config_profile mlxsw_sib_config_profile = {
+static const struct mlxsw_config_profile mlxsw_sib_config_profile = {
 	.used_max_system_port		= 1,
 	.max_system_port		= 48000,
 	.used_max_ib_mc			= 1,
diff --git a/drivers/net/ethernet/mellanox/mlxsw/switchx2.c b/drivers/net/ethernet/mellanox/mlxsw/switchx2.c
index 3b0f724..f3c29bb 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/switchx2.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/switchx2.c
@@ -1674,7 +1674,7 @@ static void mlxsw_sx_fini(struct mlxsw_core *mlxsw_core)
 	mlxsw_sx_ports_remove(mlxsw_sx);
 }
 
-static struct mlxsw_config_profile mlxsw_sx_config_profile = {
+static const struct mlxsw_config_profile mlxsw_sx_config_profile = {
 	.used_max_vepa_channels		= 1,
 	.max_vepa_channels		= 0,
 	.used_max_mid			= 1,
-- 
1.9.1
