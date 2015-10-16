From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 05/16] mlxsw: item: Make src arg of memcpy_to helper const
Date: Fri, 16 Oct 2015 14:01:26 +0200
Message-ID: <1444996897-2708-6-git-send-email-jiri@resnulli.us>
References: <1444996897-2708-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, eladr@mellanox.com,
	yotamg@mellanox.com, sfeldma@gmail.com, f.fainelli@gmail.com,
	linux@roeck-us.net, vivien.didelot@savoirfairelinux.com,
	andrew@lunn.ch, john.fastabend@gmail.com, David.Laight@ACULAB.COM,
	stephen@networkplumber.org, tgraf@suug.ch, jhs@mojatatu.com,
	sagir@mellanox.com, mattyk@mellanox.com, aviadr@mellanox.com
To: netdev@vger.kernel.org, ogerlitz@mellanox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f169.google.com ([209.85.212.169]:33160 "EHLO
	mail-wi0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753636AbbJPMBs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 Oct 2015 08:01:48 -0400
Received: by wijp11 with SMTP id p11so6931121wij.0
        for <netdev@vger.kernel.org>; Fri, 16 Oct 2015 05:01:47 -0700 (PDT)
In-Reply-To: <1444996897-2708-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@mellanox.com>

Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlxsw/item.h | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlxsw/item.h b/drivers/net/ethernet/mellanox/mlxsw/item.h
index 36fb1ce..b6ee807 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/item.h
+++ b/drivers/net/ethernet/mellanox/mlxsw/item.h
@@ -176,7 +176,7 @@ static inline void __mlxsw_item_memcpy_from(char *buf, char *dst,
 	memcpy(dst, &buf[item->offset], item->size.bytes);
 }
 
-static inline void __mlxsw_item_memcpy_to(char *buf, char *src,
+static inline void __mlxsw_item_memcpy_to(char *buf, const char *src,
 					  struct mlxsw_item *item)
 {
 	memcpy(&buf[item->offset], src, item->size.bytes);
@@ -376,7 +376,7 @@ mlxsw_##_type##_##_cname##_##_iname##_memcpy_from(char *buf, char *dst)		\
 	__mlxsw_item_memcpy_from(buf, dst, &__ITEM_NAME(_type, _cname, _iname));\
 }										\
 static inline void								\
-mlxsw_##_type##_##_cname##_##_iname##_memcpy_to(char *buf, char *src)		\
+mlxsw_##_type##_##_cname##_##_iname##_memcpy_to(char *buf, const char *src)	\
 {										\
 	__mlxsw_item_memcpy_to(buf, src, &__ITEM_NAME(_type, _cname, _iname));	\
 }
-- 
1.9.3
