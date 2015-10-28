From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 08/12] mlxsw: reg: Avoid unnecessary line wrap for mlxsw_reg_sfd_uc_unpack
Date: Wed, 28 Oct 2015 10:17:01 +0100
Message-ID: <1446023825-7162-9-git-send-email-jiri@resnulli.us>
References: <1446023825-7162-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, eladr@mellanox.com,
	yotamg@mellanox.com, ogerlitz@mellanox.com, sagir@mellanox.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f178.google.com ([209.85.212.178]:34233 "EHLO
	mail-wi0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S965264AbbJ1JRj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 28 Oct 2015 05:17:39 -0400
Received: by wikq8 with SMTP id q8so244649085wik.1
        for <netdev@vger.kernel.org>; Wed, 28 Oct 2015 02:17:38 -0700 (PDT)
In-Reply-To: <1446023825-7162-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@mellanox.com>

Signed-off-by: Jiri Pirko <jiri@mellanox.com>
Signed-off-by: Ido Schimmel <idosch@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlxsw/reg.h | 7 +++----
 1 file changed, 3 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlxsw/reg.h b/drivers/net/ethernet/mellanox/mlxsw/reg.h
index 2bf230c..236fb5d 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/reg.h
+++ b/drivers/net/ethernet/mellanox/mlxsw/reg.h
@@ -397,10 +397,9 @@ static inline void mlxsw_reg_sfd_uc_pack(char *payload, int rec_index,
 	mlxsw_reg_sfd_uc_system_port_set(payload, rec_index, local_port);
 }
 
-static inline void
-mlxsw_reg_sfd_uc_unpack(char *payload, int rec_index,
-			char *mac, u16 *p_vid,
-			u8 *p_local_port)
+static inline void mlxsw_reg_sfd_uc_unpack(char *payload, int rec_index,
+					   char *mac, u16 *p_vid,
+					   u8 *p_local_port)
 {
 	mlxsw_reg_sfd_rec_mac_memcpy_from(payload, rec_index, mac);
 	*p_vid = mlxsw_reg_sfd_uc_fid_vid_get(payload, rec_index);
-- 
1.9.3
