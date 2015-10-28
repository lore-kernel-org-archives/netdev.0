From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 12/12] mlxsw: spectrum: Make mlxsw_sp_port_switchdev_ops static
Date: Wed, 28 Oct 2015 10:17:05 +0100
Message-ID: <1446023825-7162-13-git-send-email-jiri@resnulli.us>
References: <1446023825-7162-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, eladr@mellanox.com,
	yotamg@mellanox.com, ogerlitz@mellanox.com, sagir@mellanox.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f173.google.com ([209.85.212.173]:35104 "EHLO
	mail-wi0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932678AbbJ1JRx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 28 Oct 2015 05:17:53 -0400
Received: by wicll6 with SMTP id ll6so190840176wic.0
        for <netdev@vger.kernel.org>; Wed, 28 Oct 2015 02:17:51 -0700 (PDT)
In-Reply-To: <1446023825-7162-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@mellanox.com>

Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlxsw/spectrum_switchdev.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum_switchdev.c b/drivers/net/ethernet/mellanox/mlxsw/spectrum_switchdev.c
index c2d0969..617fb22 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum_switchdev.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum_switchdev.c
@@ -732,7 +732,7 @@ static int mlxsw_sp_port_obj_dump(struct net_device *dev,
 	return err;
 }
 
-const struct switchdev_ops mlxsw_sp_port_switchdev_ops = {
+static const struct switchdev_ops mlxsw_sp_port_switchdev_ops = {
 	.switchdev_port_attr_get	= mlxsw_sp_port_attr_get,
 	.switchdev_port_attr_set	= mlxsw_sp_port_attr_set,
 	.switchdev_port_obj_add		= mlxsw_sp_port_obj_add,
-- 
1.9.3
