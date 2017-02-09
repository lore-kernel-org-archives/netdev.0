From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 06/10] mlxsw: spectrum: Change max vfid
Date: Thu,  9 Feb 2017 14:54:45 +0100
Message-ID: <1486648489-16455-7-git-send-email-jiri@resnulli.us>
References: <1486648489-16455-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, ivecera@redhat.com,
        stephen@networkplumber.org, mlxsw@mellanox.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f195.google.com ([209.85.128.195]:36255 "EHLO
        mail-wr0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752365AbdBIN4z (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 9 Feb 2017 08:56:55 -0500
Received: by mail-wr0-f195.google.com with SMTP id k90so11977652wrc.3
        for <netdev@vger.kernel.org>; Thu, 09 Feb 2017 05:54:58 -0800 (PST)
In-Reply-To: <1486648489-16455-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Nogah Frankel <nogahf@mellanox.com>

A user that wants many bridges will use 1.Q bridge which are scalable.
One can have as many 1.Q bridges as vfids.
This patch sets their number to 1k, which is a reasonably large number.
This change is done here because the next patches will add a new flood
table, and without it, it will increase the overall size of the flood
tables dramatically.

Signed-off-by: Nogah Frankel <nogahf@mellanox.com>
Signed-off-by: Yotam Gigi <yotamg@mellanox.com>
Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlxsw/spectrum.h | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum.h b/drivers/net/ethernet/mellanox/mlxsw/spectrum.h
index 145897c..49fe75f 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum.h
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum.h
@@ -55,7 +55,7 @@
 #include "core_acl_flex_actions.h"
 
 #define MLXSW_SP_VFID_BASE VLAN_N_VID
-#define MLXSW_SP_VFID_MAX 6656	/* Bridged VLAN interfaces */
+#define MLXSW_SP_VFID_MAX 1024	/* Bridged VLAN interfaces */
 
 #define MLXSW_SP_RFID_BASE 15360
 #define MLXSW_SP_INVALID_RIF 0xffff
-- 
2.7.4
