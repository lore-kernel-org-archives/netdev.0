From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 07/12] mlxsw: reg: Fix desription typos of couple of SFN items
Date: Wed, 28 Oct 2015 10:17:00 +0100
Message-ID: <1446023825-7162-8-git-send-email-jiri@resnulli.us>
References: <1446023825-7162-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, eladr@mellanox.com,
	yotamg@mellanox.com, ogerlitz@mellanox.com, sagir@mellanox.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f172.google.com ([209.85.212.172]:36865 "EHLO
	mail-wi0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S964828AbbJ1JRg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 28 Oct 2015 05:17:36 -0400
Received: by wicfv8 with SMTP id fv8so4715061wic.0
        for <netdev@vger.kernel.org>; Wed, 28 Oct 2015 02:17:35 -0700 (PDT)
In-Reply-To: <1446023825-7162-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@mellanox.com>

Fix copy-paste errors.

Signed-off-by: Jiri Pirko <jiri@mellanox.com>
Signed-off-by: Ido Schimmel <idosch@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlxsw/reg.h | 6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlxsw/reg.h b/drivers/net/ethernet/mellanox/mlxsw/reg.h
index c24283a..2bf230c 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/reg.h
+++ b/drivers/net/ethernet/mellanox/mlxsw/reg.h
@@ -475,7 +475,7 @@ MLXSW_ITEM32_INDEXED(reg, sfn, rec_type, MLXSW_REG_SFN_BASE_LEN, 20, 4,
 MLXSW_ITEM_BUF_INDEXED(reg, sfn, rec_mac, MLXSW_REG_SFN_BASE_LEN, 6,
 		       MLXSW_REG_SFN_REC_LEN, 0x02);
 
-/* reg_sfd_mac_sub_port
+/* reg_sfn_mac_sub_port
  * VEPA channel on the local port.
  * 0 if multichannel VEPA is not enabled.
  * Access: RO
@@ -483,14 +483,14 @@ MLXSW_ITEM_BUF_INDEXED(reg, sfn, rec_mac, MLXSW_REG_SFN_BASE_LEN, 6,
 MLXSW_ITEM32_INDEXED(reg, sfn, mac_sub_port, MLXSW_REG_SFN_BASE_LEN, 16, 8,
 		     MLXSW_REG_SFN_REC_LEN, 0x08, false);
 
-/* reg_sfd_mac_fid
+/* reg_sfn_mac_fid
  * Filtering identifier.
  * Access: RO
  */
 MLXSW_ITEM32_INDEXED(reg, sfn, mac_fid, MLXSW_REG_SFN_BASE_LEN, 0, 16,
 		     MLXSW_REG_SFN_REC_LEN, 0x08, false);
 
-/* reg_sfd_mac_system_port
+/* reg_sfn_mac_system_port
  * Unique port identifier for the final destination of the packet.
  * Access: RO
  */
-- 
1.9.3
