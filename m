From: Stephen Hemminger <stephen@networkplumber.org>
Subject: [PATCH net-next 3/8] batman: make netlink attributes const
Date: Wed, 31 Aug 2016 15:17:00 -0700
Message-ID: <20160831151700.1bbc91f2@xeon-e3>
References: <20160831151445.6c8e4e06@xeon-e3>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>,
        Marek Lindner <mareklindner@neomailbox.ch>,
        Simon Wunderlich <sw@simonwunderlich.de>,
        Antonio Quartulli <a@unstable.cc>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f172.google.com ([209.85.192.172]:32903 "EHLO
        mail-pf0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751263AbcIAGZK (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 1 Sep 2016 02:25:10 -0400
Received: by mail-pf0-f172.google.com with SMTP id g202so4757171pfb.0
        for <netdev@vger.kernel.org>; Wed, 31 Aug 2016 23:25:09 -0700 (PDT)
In-Reply-To: <20160831151445.6c8e4e06@xeon-e3>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Signed-off-by: Stephen Hemminger <stephen@networkplumber.org>
---
 net/batman-adv/netlink.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/batman-adv/netlink.c b/net/batman-adv/netlink.c
index 18831e7..64cb6ac 100644
--- a/net/batman-adv/netlink.c
+++ b/net/batman-adv/netlink.c
@@ -62,11 +62,11 @@ enum batadv_netlink_multicast_groups {
 	BATADV_NL_MCGRP_TPMETER,
 };
 
-static struct genl_multicast_group batadv_netlink_mcgrps[] = {
+static const struct genl_multicast_group batadv_netlink_mcgrps[] = {
 	[BATADV_NL_MCGRP_TPMETER] = { .name = BATADV_NL_MCAST_GROUP_TPMETER },
 };
 
-static struct nla_policy batadv_netlink_policy[NUM_BATADV_ATTR] = {
+static const struct nla_policy batadv_netlink_policy[NUM_BATADV_ATTR] = {
 	[BATADV_ATTR_VERSION]		= { .type = NLA_STRING },
 	[BATADV_ATTR_ALGO_NAME]		= { .type = NLA_STRING },
 	[BATADV_ATTR_MESH_IFINDEX]	= { .type = NLA_U32 },
-- 
2.9.3
