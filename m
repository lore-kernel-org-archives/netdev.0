From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 36/42] mlxsw: spectrum: Define sizes of KVD areas
Date: Fri,  1 Jul 2016 16:05:04 +0200
Message-ID: <1467381910-3445-37-git-send-email-jiri@resnulli.us>
References: <1467381910-3445-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, yotamg@mellanox.com,
	eladr@mellanox.com, nogahf@mellanox.com, ogerlitz@mellanox.com,
	sfeldma@gmail.com, roopa@cumulusnetworks.com, andy@greyhouse.net,
	dsa@cumulusnetworks.com, tgraf@suug.ch, jhs@mojatatu.com,
	linville@tuxdriver.com, ivecera@redhat.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f65.google.com ([74.125.82.65]:34774 "EHLO
	mail-wm0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752296AbcGAOUR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 1 Jul 2016 10:20:17 -0400
Received: by mail-wm0-f65.google.com with SMTP id 187so5673461wmz.1
        for <netdev@vger.kernel.org>; Fri, 01 Jul 2016 07:20:17 -0700 (PDT)
In-Reply-To: <1467381910-3445-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@mellanox.com>

Override the defaults and define the area sizes ourselves.

Signed-off-by: Jiri Pirko <jiri@mellanox.com>
Reviewed-by: Ido Schimmel <idosch@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlxsw/spectrum.c | 4 ++++
 drivers/net/ethernet/mellanox/mlxsw/spectrum.h | 4 ++++
 2 files changed, 8 insertions(+)

diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum.c b/drivers/net/ethernet/mellanox/mlxsw/spectrum.c
index 9bebb7a..c812513 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum.c
@@ -2356,6 +2356,10 @@ static struct mlxsw_config_profile mlxsw_sp_config_profile = {
 	.max_ib_mc			= 0,
 	.used_max_pkey			= 1,
 	.max_pkey			= 0,
+	.used_kvd_sizes			= 1,
+	.kvd_linear_size		= MLXSW_SP_KVD_LINEAR_SIZE,
+	.kvd_hash_single_size		= MLXSW_SP_KVD_HASH_SINGLE_SIZE,
+	.kvd_hash_double_size		= MLXSW_SP_KVD_HASH_DOUBLE_SIZE,
 	.swid_config			= {
 		{
 			.used_type	= 1,
diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum.h b/drivers/net/ethernet/mellanox/mlxsw/spectrum.h
index 9c2a60f..f7d34d8 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum.h
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum.h
@@ -76,6 +76,10 @@
 #define MLXSW_SP_BYTES_TO_CELLS(b) DIV_ROUND_UP(b, MLXSW_SP_BYTES_PER_CELL)
 #define MLXSW_SP_CELLS_TO_BYTES(c) (c * MLXSW_SP_BYTES_PER_CELL)
 
+#define MLXSW_SP_KVD_LINEAR_SIZE 65536 /* entries */
+#define MLXSW_SP_KVD_HASH_SINGLE_SIZE 163840 /* entries */
+#define MLXSW_SP_KVD_HASH_DOUBLE_SIZE 32768 /* entries */
+
 /* Maximum delay buffer needed in case of PAUSE frames, in cells.
  * Assumes 100m cable and maximum MTU.
  */
-- 
2.5.5
