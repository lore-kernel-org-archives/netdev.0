From: Andreas Schultz <aschultz@tpip.net>
Subject: [PATCH 1/5] gtp: add genl family modules alias
Date: Tue, 24 Jan 2017 18:23:58 +0100
Message-ID: <20170124172402.12096-2-aschultz@tpip.net>
References: <20170124172402.12096-1-aschultz@tpip.net>
Cc: netdev@vger.kernel.org,
        Lionel Gauthier <Lionel.Gauthier@eurecom.fr>,
        openbsc@lists.osmocom.org, Harald Welte <laforge@gnumonks.org>
To: Pablo Neira <pablo@netfilter.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.tpip.net ([92.43.49.48]:52026 "EHLO mail.tpip.net"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750716AbdAXRYI (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 24 Jan 2017 12:24:08 -0500
In-Reply-To: <20170124172402.12096-1-aschultz@tpip.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Auto-load the module when userspace asks for the gtp netlink
family.

Signed-off-by: Andreas Schultz <aschultz@tpip.net>
---
 drivers/net/gtp.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/drivers/net/gtp.c b/drivers/net/gtp.c
index 8b6810b..7580ccc 100644
--- a/drivers/net/gtp.c
+++ b/drivers/net/gtp.c
@@ -1376,3 +1376,4 @@ MODULE_LICENSE("GPL");
 MODULE_AUTHOR("Harald Welte <hwelte@sysmocom.de>");
 MODULE_DESCRIPTION("Interface driver for GTP encapsulated traffic");
 MODULE_ALIAS_RTNL_LINK("gtp");
+MODULE_ALIAS_GENL_FAMILY("gtp");
-- 
2.10.2
