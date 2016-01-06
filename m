From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 2/8] switchdev: add bridge vlan_filtering attribute
Date: Wed,  6 Jan 2016 11:11:50 +0100
Message-ID: <1452075116-5726-3-git-send-email-jiri@resnulli.us>
References: <1452075116-5726-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, eladr@mellanox.com,
	yotamg@mellanox.com, ogerlitz@mellanox.com,
	stephen@networkplumber.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f44.google.com ([74.125.82.44]:34448 "EHLO
	mail-wm0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752278AbcAFKMC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Jan 2016 05:12:02 -0500
Received: by mail-wm0-f44.google.com with SMTP id u188so54430543wmu.1
        for <netdev@vger.kernel.org>; Wed, 06 Jan 2016 02:12:01 -0800 (PST)
In-Reply-To: <1452075116-5726-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Elad Raz <eladr@mellanox.com>

Adding vlan_filtering attribute to allow hardware vendor to support
vlan-aware bridges. Vlan_filtering is a per-bridge attribute.

Signed-off-by: Elad Raz <eladr@mellanox.com>
Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 include/net/switchdev.h | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/include/net/switchdev.h b/include/net/switchdev.h
index 6612946..603ae2f 100644
--- a/include/net/switchdev.h
+++ b/include/net/switchdev.h
@@ -47,6 +47,7 @@ enum switchdev_attr_id {
 	SWITCHDEV_ATTR_ID_PORT_STP_STATE,
 	SWITCHDEV_ATTR_ID_PORT_BRIDGE_FLAGS,
 	SWITCHDEV_ATTR_ID_BRIDGE_AGEING_TIME,
+	SWITCHDEV_ATTR_ID_BRIDGE_VLAN_FILTERING,
 };
 
 struct switchdev_attr {
@@ -58,6 +59,7 @@ struct switchdev_attr {
 		u8 stp_state;				/* PORT_STP_STATE */
 		unsigned long brport_flags;		/* PORT_BRIDGE_FLAGS */
 		u32 ageing_time;			/* BRIDGE_AGEING_TIME */
+		bool vlan_filtering;			/* BRIDGE_VLAN_FILTERING */
 	} u;
 };
 
-- 
1.9.3
