From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net 1/2] mlxsw: switchx2: changing order of exit fallbacks
Date: Thu,  8 Oct 2015 15:17:37 +0200
Message-ID: <1444310258-6563-2-git-send-email-jiri@resnulli.us>
References: <1444310258-6563-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, eladr@mellanox.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f176.google.com ([209.85.212.176]:33522 "EHLO
	mail-wi0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757534AbbJHNRm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 Oct 2015 09:17:42 -0400
Received: by wiclk2 with SMTP id lk2so28005156wic.0
        for <netdev@vger.kernel.org>; Thu, 08 Oct 2015 06:17:41 -0700 (PDT)
In-Reply-To: <1444310258-6563-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Elad Raz <eladr@mellanox.com>

Fixes: 31557f0f9755 ("mlxsw: Introduce Mellanox SwitchX-2 ASIC support")
Signed-off-by: Elad Raz <eladr@mellanox.com>
Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlxsw/switchx2.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/mellanox/mlxsw/switchx2.c b/drivers/net/ethernet/mellanox/mlxsw/switchx2.c
index d448431..633f3e7 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/switchx2.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/switchx2.c
@@ -1069,9 +1069,9 @@ static int mlxsw_sx_port_create(struct mlxsw_sx *mlxsw_sx, u8 local_port)
 	return 0;
 
 err_register_netdev:
-err_port_admin_status_set:
 err_port_mac_learning_mode_set:
 err_port_stp_state_set:
+err_port_admin_status_set:
 err_port_mtu_set:
 err_port_speed_set:
 err_port_swid_set:
-- 
1.9.3
