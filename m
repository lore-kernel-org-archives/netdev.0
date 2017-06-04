From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next] mlxsw: spectrum: Rename the firmware file
Date: Sun,  4 Jun 2017 16:49:58 +0200
Message-ID: <20170604144958.14358-1-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, yotamg@mellanox.com,
        mlxsw@mellanox.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f193.google.com ([209.85.128.193]:34938 "EHLO
        mail-wr0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751214AbdFDOuC (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 4 Jun 2017 10:50:02 -0400
Received: by mail-wr0-f193.google.com with SMTP id g76so5286352wrd.2
        for <netdev@vger.kernel.org>; Sun, 04 Jun 2017 07:50:01 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Yotam Gigi <yotamg@mellanox.com>

Change the firmware file name to be in "mellanox" directory.

This commit is a followup to the linux-firmware commit a4c72696f5f4
("Mellanox: Add firmware for mlxsw_spectrum")

Signed-off-by: Yotam Gigi <yotamg@mellanox.com>
Reviewed-by: Ido Schimmel <idosch@mellanox.com>
Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlxsw/spectrum.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum.c b/drivers/net/ethernet/mellanox/mlxsw/spectrum.c
index 1e6a97d..84b6f36 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum.c
@@ -81,7 +81,7 @@ static const struct mlxsw_fw_rev mlxsw_sp_supported_fw_rev = {
 };
 
 #define MLXSW_SP_FW_FILENAME \
-	"mlxsw_spectrum-" __stringify(MLXSW_FWREV_MAJOR) \
+	"mellanox/mlxsw_spectrum-" __stringify(MLXSW_FWREV_MAJOR) \
 	"." __stringify(MLXSW_FWREV_MINOR) \
 	"." __stringify(MLXSW_FWREV_SUBMINOR) ".mfa2"
 
-- 
2.9.3
