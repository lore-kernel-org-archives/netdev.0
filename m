From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 06/12] mlxsw: reg: Fix description for reg_sfd_uc_sub_port
Date: Wed, 28 Oct 2015 10:16:59 +0100
Message-ID: <1446023825-7162-7-git-send-email-jiri@resnulli.us>
References: <1446023825-7162-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, eladr@mellanox.com,
	yotamg@mellanox.com, ogerlitz@mellanox.com, sagir@mellanox.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f52.google.com ([74.125.82.52]:32798 "EHLO
	mail-wm0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754826AbbJ1JXY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 28 Oct 2015 05:23:24 -0400
Received: by wmeg8 with SMTP id g8so5306001wme.0
        for <netdev@vger.kernel.org>; Wed, 28 Oct 2015 02:23:23 -0700 (PDT)
In-Reply-To: <1446023825-7162-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@mellanox.com>

The original description was for LAG, so fix it.

Signed-off-by: Jiri Pirko <jiri@mellanox.com>
Signed-off-by: Ido Schimmel <idosch@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlxsw/reg.h | 5 +++--
 1 file changed, 3 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlxsw/reg.h b/drivers/net/ethernet/mellanox/mlxsw/reg.h
index 4fcba46..c24283a 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/reg.h
+++ b/drivers/net/ethernet/mellanox/mlxsw/reg.h
@@ -348,8 +348,9 @@ MLXSW_ITEM32_INDEXED(reg, sfd, rec_action, MLXSW_REG_SFD_BASE_LEN, 28, 4,
 		     MLXSW_REG_SFD_REC_LEN, 0x0C, false);
 
 /* reg_sfd_uc_sub_port
- * LAG sub port.
- * Must be 0 if multichannel VEPA is not enabled.
+ * VEPA channel on local port.
+ * Valid only if local port is a non-stacking port. Must be 0 if multichannel
+ * VEPA is not enabled.
  * Access: RW
  */
 MLXSW_ITEM32_INDEXED(reg, sfd, uc_sub_port, MLXSW_REG_SFD_BASE_LEN, 16, 8,
-- 
1.9.3
