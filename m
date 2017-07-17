From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 1/6] mlxsw: acl: Add ip ttl acl element
Date: Mon, 17 Jul 2017 14:07:26 +0200
Message-ID: <20170717120731.3875-2-jiri@resnulli.us>
References: <20170717120731.3875-1-jiri@resnulli.us>
Cc: davem@davemloft.net, ogerlitz@mellanox.com, idosch@mellanox.com,
        mlxsw@mellanox.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f67.google.com ([74.125.82.67]:33314 "EHLO
        mail-wm0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751320AbdGQMHg (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 17 Jul 2017 08:07:36 -0400
Received: by mail-wm0-f67.google.com with SMTP id 65so2862933wmf.0
        for <netdev@vger.kernel.org>; Mon, 17 Jul 2017 05:07:36 -0700 (PDT)
In-Reply-To: <20170717120731.3875-1-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Or Gerlitz <ogerlitz@mellanox.com>

Define new element for ip ttl and place it into scratch area.

Signed-off-by: Or Gerlitz <ogerlitz@mellanox.com>
Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlxsw/core_acl_flex_keys.h | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/drivers/net/ethernet/mellanox/mlxsw/core_acl_flex_keys.h b/drivers/net/ethernet/mellanox/mlxsw/core_acl_flex_keys.h
index 9807ef8..789ebb3 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/core_acl_flex_keys.h
+++ b/drivers/net/ethernet/mellanox/mlxsw/core_acl_flex_keys.h
@@ -57,6 +57,7 @@ enum mlxsw_afk_element {
 	MLXSW_AFK_ELEMENT_VID,
 	MLXSW_AFK_ELEMENT_PCP,
 	MLXSW_AFK_ELEMENT_TCP_FLAGS,
+	MLXSW_AFK_ELEMENT_IP_TTL_,
 	MLXSW_AFK_ELEMENT_MAX,
 };
 
@@ -104,6 +105,7 @@ static const struct mlxsw_afk_element_info mlxsw_afk_element_infos[] = {
 	MLXSW_AFK_ELEMENT_INFO_U32(VID, 0x10, 8, 12),
 	MLXSW_AFK_ELEMENT_INFO_U32(PCP, 0x10, 20, 3),
 	MLXSW_AFK_ELEMENT_INFO_U32(TCP_FLAGS, 0x10, 23, 9),
+	MLXSW_AFK_ELEMENT_INFO_U32(IP_TTL_, 0x14, 0, 8),
 	MLXSW_AFK_ELEMENT_INFO_U32(SRC_IP4, 0x18, 0, 32),
 	MLXSW_AFK_ELEMENT_INFO_U32(DST_IP4, 0x1C, 0, 32),
 	MLXSW_AFK_ELEMENT_INFO_BUF(SRC_IP6_HI, 0x18, 8),
-- 
2.9.3
