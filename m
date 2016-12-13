From: Roi Dayan <roid@mellanox.com>
Subject: [PATCH iproute2 V2 1/2] tc: flower: Fix typo and style in flower man page
Date: Tue, 13 Dec 2016 14:39:01 +0200
Message-ID: <1481632742-18020-2-git-send-email-roid@mellanox.com>
References: <1481632742-18020-1-git-send-email-roid@mellanox.com>
Cc: netdev@vger.kernel.org, Amir Vadai <amir@vadai.me>,
        Hadar Hen Zion <hadarh@mellanox.com>,
        Roi Dayan <roid@mellanox.com>
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:38419 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S932238AbcLMMku (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 13 Dec 2016 07:40:50 -0500
In-Reply-To: <1481632742-18020-1-git-send-email-roid@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Replace vlan_eth_type with vlan_ethtype.

Fixes: 745d91726006 ("tc: flower: Introduce vlan support")
Signed-off-by: Roi Dayan <roid@mellanox.com>
Reviewed-by: Hadar Hen Zion <hadarh@mellanox.com>
---
 man/man8/tc-flower.8 | 10 +++++-----
 1 file changed, 5 insertions(+), 5 deletions(-)

diff --git a/man/man8/tc-flower.8 b/man/man8/tc-flower.8
index 90fdfba..15bc32f 100644
--- a/man/man8/tc-flower.8
+++ b/man/man8/tc-flower.8
@@ -27,7 +27,7 @@ flower \- flow based traffic control filter
 .IR VID " | "
 .B vlan_prio
 .IR PRIORITY " | "
-.BR vlan_eth_type " { " ipv4 " | " ipv6 " | "
+.BR vlan_ethtype " { " ipv4 " | " ipv6 " | "
 .IR ETH_TYPE " } | "
 .BR ip_proto " { " tcp " | " udp " | " sctp " | " icmp " | " icmpv6 " | "
 .IR IP_PROTO " } | { "
@@ -82,16 +82,16 @@ Match on vlan tag id.
 .I VID
 is an unsigned 12bit value in decimal format.
 .TP
-.BI vlan_prio " priority"
+.BI vlan_prio " PRIORITY"
 Match on vlan tag priority.
 .I PRIORITY
 is an unsigned 3bit value in decimal format.
 .TP
-.BI vlan_eth_type " VLAN_ETH_TYPE"
+.BI vlan_ethtype " VLAN_ETH_TYPE"
 Match on layer three protocol.
-.I ETH_TYPE
+.I VLAN_ETH_TYPE
 may be either
-.BR ipv4 , ipv6
+.BR ipv4 ", " ipv6
 or an unsigned 16bit value in hexadecimal format.
 .TP
 .BI ip_proto " IP_PROTO"
-- 
2.7.4
