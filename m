From: Simon Wunderlich <sw@simonwunderlich.de>
Subject: [PATCH 7/8] batman-adv: Add module alias for batadv netlink family
Date: Sat, 19 Nov 2016 14:35:27 +0100
Message-ID: <20161119133528.1379-8-sw@simonwunderlich.de>
References: <20161119133528.1379-1-sw@simonwunderlich.de>
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org,
        Sven Eckelmann <sven@narfation.org>,
        Simon Wunderlich <sw@simonwunderlich.de>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from packetmixer.de ([79.140.42.25]:49980 "EHLO
        mail.mail.packetmixer.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752814AbcKSNfe (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 19 Nov 2016 08:35:34 -0500
In-Reply-To: <20161119133528.1379-1-sw@simonwunderlich.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sven Eckelmann <sven@narfation.org>

The batman-adv module has to be loaded to fulfill genl request by the
userspace. When it is not loaded then requests will fail. It is therefore
useful to get the module automatically loaded when such a request is made.

Signed-off-by: Sven Eckelmann <sven@narfation.org>
Signed-off-by: Simon Wunderlich <sw@simonwunderlich.de>
---
 net/batman-adv/main.c | 3 +++
 1 file changed, 3 insertions(+)

diff --git a/net/batman-adv/main.c b/net/batman-adv/main.c
index 6b5dae6..d46415e 100644
--- a/net/batman-adv/main.c
+++ b/net/batman-adv/main.c
@@ -23,6 +23,7 @@
 #include <linux/crc32c.h>
 #include <linux/errno.h>
 #include <linux/fs.h>
+#include <linux/genetlink.h>
 #include <linux/if_ether.h>
 #include <linux/if_vlan.h>
 #include <linux/init.h>
@@ -44,6 +45,7 @@
 #include <linux/workqueue.h>
 #include <net/dsfield.h>
 #include <net/rtnetlink.h>
+#include <uapi/linux/batman_adv.h>
 
 #include "bat_algo.h"
 #include "bat_iv_ogm.h"
@@ -648,3 +650,4 @@ MODULE_DESCRIPTION(BATADV_DRIVER_DESC);
 MODULE_SUPPORTED_DEVICE(BATADV_DRIVER_DEVICE);
 MODULE_VERSION(BATADV_SOURCE_VERSION);
 MODULE_ALIAS_RTNL_LINK("batadv");
+MODULE_ALIAS_GENL_FAMILY(BATADV_NL_NAME);
-- 
2.10.2
