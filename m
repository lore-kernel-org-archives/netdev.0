From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 09/12] mlxsw: reg: Add FDB action to forward to router
Date: Sat,  2 Jul 2016 11:00:17 +0200
Message-ID: <1467450020-23415-10-git-send-email-jiri@resnulli.us>
References: <1467450020-23415-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, yotamg@mellanox.com,
	eladr@mellanox.com, nogahf@mellanox.com, ogerlitz@mellanox.com,
	sfeldma@gmail.com, roopa@cumulusnetworks.com, andy@greyhouse.net,
	dsa@cumulusnetworks.com, tgraf@suug.ch, jhs@mojatatu.com,
	linville@tuxdriver.com, ivecera@redhat.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f68.google.com ([74.125.82.68]:36373 "EHLO
	mail-wm0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752252AbcGBJAg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 2 Jul 2016 05:00:36 -0400
Received: by mail-wm0-f68.google.com with SMTP id c82so10282899wme.3
        for <netdev@vger.kernel.org>; Sat, 02 Jul 2016 02:00:36 -0700 (PDT)
In-Reply-To: <1467450020-23415-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ido Schimmel <idosch@mellanox.com>

Incoming packets are directed to the router when they match an FDB
entry with action forward to IP router.

Add this action, which was mistakenly named "TRAP".

Signed-off-by: Ido Schimmel <idosch@mellanox.com>
Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlxsw/reg.h | 4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/mellanox/mlxsw/reg.h b/drivers/net/ethernet/mellanox/mlxsw/reg.h
index 7f74eb7..ea05e83 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/reg.h
+++ b/drivers/net/ethernet/mellanox/mlxsw/reg.h
@@ -386,7 +386,9 @@ enum mlxsw_reg_sfd_rec_action {
 	/* forward and trap, trap_id is FDB_TRAP */
 	MLXSW_REG_SFD_REC_ACTION_MIRROR_TO_CPU = 1,
 	/* trap and do not forward, trap_id is FDB_TRAP */
-	MLXSW_REG_SFD_REC_ACTION_TRAP = 3,
+	MLXSW_REG_SFD_REC_ACTION_TRAP = 2,
+	/* forward to IP router */
+	MLXSW_REG_SFD_REC_ACTION_FORWARD_IP_ROUTER = 3,
 	MLXSW_REG_SFD_REC_ACTION_DISCARD_ERROR = 15,
 };
 
-- 
2.5.5
