From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 07/12] mlxsw: spectrum_dpipe: Fix label name
Date: Thu, 24 Aug 2017 08:40:05 +0200
Message-ID: <20170824064010.1646-8-jiri@resnulli.us>
References: <20170824064010.1646-1-jiri@resnulli.us>
Cc: davem@davemloft.net, arkadis@mellanox.com, idosch@mellanox.com,
        mlxsw@mellanox.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f194.google.com ([209.85.128.194]:37828 "EHLO
        mail-wr0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751994AbdHXGkZ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 24 Aug 2017 02:40:25 -0400
Received: by mail-wr0-f194.google.com with SMTP id 72so957314wrc.4
        for <netdev@vger.kernel.org>; Wed, 23 Aug 2017 23:40:25 -0700 (PDT)
In-Reply-To: <20170824064010.1646-1-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Arkadi Sharshevsky <arkadis@mellanox.com>

Change label name for case of erif table init failure.

Signed-off-by: Arkadi Sharshevsky <arkadis@mellanox.com>
Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlxsw/spectrum_dpipe.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum_dpipe.c b/drivers/net/ethernet/mellanox/mlxsw/spectrum_dpipe.c
index 1305df9..6310c2c 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum_dpipe.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum_dpipe.c
@@ -324,10 +324,10 @@ int mlxsw_sp_dpipe_init(struct mlxsw_sp *mlxsw_sp)
 		return err;
 	err = mlxsw_sp_dpipe_erif_table_init(mlxsw_sp);
 	if (err)
-		goto err_erif_register;
+		goto err_erif_table_init;
 	return 0;
 
-err_erif_register:
+err_erif_table_init:
 	devlink_dpipe_headers_unregister(priv_to_devlink(mlxsw_sp->core));
 	return err;
 }
-- 
2.9.3
