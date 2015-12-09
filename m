From: Dan Carpenter <dan.carpenter@oracle.com>
Subject: [patch -next] mlxsw: core: remove an unneeded condition
Date: Wed, 9 Dec 2015 13:41:29 +0300
Message-ID: <20151209104129.GJ3173@mwanda>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Ido Schimmel <idosch@mellanox.com>, netdev@vger.kernel.org,
	kernel-janitors@vger.kernel.org
To: Jiri Pirko <jiri@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from aserp1040.oracle.com ([141.146.126.69]:33231 "EHLO
	aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754181AbbLIKll (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Dec 2015 05:41:41 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We already know "err" is zero so there is no need to check.

Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>

diff --git a/drivers/net/ethernet/mellanox/mlxsw/core_hwmon.c b/drivers/net/ethernet/mellanox/mlxsw/core_hwmon.c
index 4dad146..913106d 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/core_hwmon.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/core_hwmon.c
@@ -169,7 +169,7 @@ static ssize_t mlxsw_hwmon_pwm_store(struct device *dev,
 		dev_err(mlxsw_hwmon->bus_info->dev, "Failed to write PWM\n");
 		return err;
 	}
-	return err ? err : len;
+	return len;
 }
 
 enum mlxsw_hwmon_attr_type {
