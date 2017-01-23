From: Andreas Schultz <aschultz@tpip.net>
Subject: [PATCH 01/17] gtp: add genl family modules alias
Date: Mon, 23 Jan 2017 12:56:50 +0100
Message-ID: <20170123115706.4354-2-aschultz@tpip.net>
References: <20170123115706.4354-1-aschultz@tpip.net>
Cc: netdev@vger.kernel.org, Harald Welte <laforge@gnumonks.org>,
        Lionel Gauthier <Lionel.Gauthier@eurecom.fr>,
        openbsc@lists.osmocom.org
To: Pablo Neira <pablo@netfilter.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.tpip.net ([92.43.49.48]:46786 "EHLO mail.tpip.net"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751013AbdAWMGy (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 23 Jan 2017 07:06:54 -0500
In-Reply-To: <20170123115706.4354-1-aschultz@tpip.net>
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
