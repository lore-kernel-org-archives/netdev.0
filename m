From: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
Subject: [PATCH net-next] net: bridge: add neigh_suppress to bridge port policies
Date: Mon, 30 Oct 2017 12:56:33 +0200
Message-ID: <1509360993-25227-1-git-send-email-nikolay@cumulusnetworks.com>
Cc: roopa@cumulusnetworks.com, davem@davemloft.net,
        bridge@lists.linux-foundation.org, stephen@networkplumber.org,
        Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f65.google.com ([74.125.82.65]:48321 "EHLO
        mail-wm0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751917AbdJ3K4m (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 30 Oct 2017 06:56:42 -0400
Received: by mail-wm0-f65.google.com with SMTP id p75so14975820wmg.3
        for <netdev@vger.kernel.org>; Mon, 30 Oct 2017 03:56:42 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add an entry for IFLA_BRPORT_NEIGH_SUPPRESS to bridge port policies.

Fixes: 821f1b21cabb ("bridge: add new BR_NEIGH_SUPPRESS port flag to suppress arp and nd flood")
Signed-off-by: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
---
 net/bridge/br_netlink.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/net/bridge/br_netlink.c b/net/bridge/br_netlink.c
index e732403669c6..26aeb0b5cf30 100644
--- a/net/bridge/br_netlink.c
+++ b/net/bridge/br_netlink.c
@@ -651,6 +651,7 @@ static const struct nla_policy br_port_policy[IFLA_BRPORT_MAX + 1] = {
 	[IFLA_BRPORT_MCAST_FLOOD] = { .type = NLA_U8 },
 	[IFLA_BRPORT_BCAST_FLOOD] = { .type = NLA_U8 },
 	[IFLA_BRPORT_GROUP_FWD_MASK] = { .type = NLA_U16 },
+	[IFLA_BRPORT_NEIGH_SUPPRESS] = { .type = NLA_U8 },
 };
 
 /* Change the state of the port and notify spanning tree */
-- 
2.1.4
