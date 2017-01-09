From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 1/5] mlxsw: Fix mlxsw_i2c_write return value
Date: Mon,  9 Jan 2017 11:25:44 +0100
Message-ID: <1483957548-3531-2-git-send-email-jiri@resnulli.us>
References: <1483957548-3531-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, eladr@mellanox.com,
        yotamg@mellanox.com, nogahf@mellanox.com, arkadis@mellanox.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f67.google.com ([74.125.82.67]:33076 "EHLO
        mail-wm0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751948AbdAIKZw (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 9 Jan 2017 05:25:52 -0500
Received: by mail-wm0-f67.google.com with SMTP id r144so12136681wme.0
        for <netdev@vger.kernel.org>; Mon, 09 Jan 2017 02:25:51 -0800 (PST)
In-Reply-To: <1483957548-3531-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Elad Raz <eladr@mellanox.com>

The "err" variable is been checked, return always 0.

Signed-off-by: Elad Raz <eladr@mellanox.com>
Acked-by: Ido Schimmel <idosch@mellanox.com>
Acked-by: Vadim Pasternak <vadimp@mellanox.com>
Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlxsw/i2c.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/mellanox/mlxsw/i2c.c b/drivers/net/ethernet/mellanox/mlxsw/i2c.c
index e50c8db..12c3a44 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/i2c.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/i2c.c
@@ -338,7 +338,7 @@ mlxsw_i2c_write(struct device *dev, size_t in_mbox_size, u8 *in_mbox, int num,
 		return -EIO;
 	}
 
-	return err > 0 ? 0 : err;
+	return 0;
 }
 
 /* Routine executes I2C command. */
-- 
2.7.4
