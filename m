From: Nikolay Aleksandrov <razor@blackwall.org>
Subject: [PATCH iproute2] iplink: bridge: remove unnecessary returns
Date: Thu, 18 Feb 2016 20:54:34 +0100
Message-ID: <1455825274-8001-1-git-send-email-razor@blackwall.org>
Cc: stephen@networkplumber.org,
	Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f49.google.com ([74.125.82.49]:36360 "EHLO
	mail-wm0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1425165AbcBRTyp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 18 Feb 2016 14:54:45 -0500
Received: by mail-wm0-f49.google.com with SMTP id g62so45253769wme.1
        for <netdev@vger.kernel.org>; Thu, 18 Feb 2016 11:54:45 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>

invarg exits so no need to return, remove this c&p error from my recent
patches

Signed-off-by: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
---
 ip/iplink_bridge.c | 50 ++++++++++++++++++++------------------------------
 1 file changed, 20 insertions(+), 30 deletions(-)

diff --git a/ip/iplink_bridge.c b/ip/iplink_bridge.c
index 79f15eff7c39..d2d4202660eb 100644
--- a/ip/iplink_bridge.c
+++ b/ip/iplink_bridge.c
@@ -116,19 +116,17 @@ static int bridge_parse_opt(struct link_util *lu, int argc, char **argv,
 			__u8 vlan_filter;
 
 			NEXT_ARG();
-			if (get_u8(&vlan_filter, *argv, 0)) {
+			if (get_u8(&vlan_filter, *argv, 0))
 				invarg("invalid vlan_filtering", *argv);
-				return -1;
-			}
+
 			addattr8(n, 1024, IFLA_BR_VLAN_FILTERING, vlan_filter);
 		} else if (matches(*argv, "vlan_protocol") == 0) {
 			__u16 vlan_proto;
 
 			NEXT_ARG();
-			if (ll_proto_a2n(&vlan_proto, *argv)) {
+			if (ll_proto_a2n(&vlan_proto, *argv))
 				invarg("invalid vlan_protocol", *argv);
-				return -1;
-			}
+
 			addattr16(n, 1024, IFLA_BR_VLAN_PROTOCOL, vlan_proto);
 		} else if (matches(*argv, "group_fwd_mask") == 0) {
 			__u16 fwd_mask;
@@ -243,85 +241,77 @@ static int bridge_parse_opt(struct link_util *lu, int argc, char **argv,
 			__u64 mcast_membership_intvl;
 
 			NEXT_ARG();
-			if (get_u64(&mcast_membership_intvl, *argv, 0)) {
+			if (get_u64(&mcast_membership_intvl, *argv, 0))
 				invarg("invalid mcast_membership_interval",
 				       *argv);
-				return -1;
-			}
+
 			addattr64(n, 1024, IFLA_BR_MCAST_MEMBERSHIP_INTVL,
 				  mcast_membership_intvl);
 		} else if (matches(*argv, "mcast_querier_interval") == 0) {
 			__u64 mcast_querier_intvl;
 
 			NEXT_ARG();
-			if (get_u64(&mcast_querier_intvl, *argv, 0)) {
+			if (get_u64(&mcast_querier_intvl, *argv, 0))
 				invarg("invalid mcast_querier_interval",
 				       *argv);
-				return -1;
-			}
+
 			addattr64(n, 1024, IFLA_BR_MCAST_QUERIER_INTVL,
 				  mcast_querier_intvl);
 		} else if (matches(*argv, "mcast_query_interval") == 0) {
 			__u64 mcast_query_intvl;
 
 			NEXT_ARG();
-			if (get_u64(&mcast_query_intvl, *argv, 0)) {
+			if (get_u64(&mcast_query_intvl, *argv, 0))
 				invarg("invalid mcast_query_interval",
 				       *argv);
-				return -1;
-			}
+
 			addattr64(n, 1024, IFLA_BR_MCAST_QUERY_INTVL,
 				  mcast_query_intvl);
 		} else if (!matches(*argv, "mcast_query_response_interval")) {
 			__u64 mcast_query_resp_intvl;
 
 			NEXT_ARG();
-			if (get_u64(&mcast_query_resp_intvl, *argv, 0)) {
+			if (get_u64(&mcast_query_resp_intvl, *argv, 0))
 				invarg("invalid mcast_query_response_interval",
 				       *argv);
-				return -1;
-			}
+
 			addattr64(n, 1024, IFLA_BR_MCAST_QUERY_RESPONSE_INTVL,
 				  mcast_query_resp_intvl);
 		} else if (!matches(*argv, "mcast_startup_query_interval")) {
 			__u64 mcast_startup_query_intvl;
 
 			NEXT_ARG();
-			if (get_u64(&mcast_startup_query_intvl, *argv, 0)) {
+			if (get_u64(&mcast_startup_query_intvl, *argv, 0))
 				invarg("invalid mcast_startup_query_interval",
 				       *argv);
-				return -1;
-			}
+
 			addattr64(n, 1024, IFLA_BR_MCAST_STARTUP_QUERY_INTVL,
 				  mcast_startup_query_intvl);
 		} else if (matches(*argv, "nf_call_iptables") == 0) {
 			__u8 nf_call_ipt;
 
 			NEXT_ARG();
-			if (get_u8(&nf_call_ipt, *argv, 0)) {
+			if (get_u8(&nf_call_ipt, *argv, 0))
 				invarg("invalid nf_call_iptables", *argv);
-				return -1;
-			}
+
 			addattr8(n, 1024, IFLA_BR_NF_CALL_IPTABLES,
 				 nf_call_ipt);
 		} else if (matches(*argv, "nf_call_ip6tables") == 0) {
 			__u8 nf_call_ip6t;
 
 			NEXT_ARG();
-			if (get_u8(&nf_call_ip6t, *argv, 0)) {
+			if (get_u8(&nf_call_ip6t, *argv, 0))
 				invarg("invalid nf_call_ip6tables", *argv);
-				return -1;
-			}
+
 			addattr8(n, 1024, IFLA_BR_NF_CALL_IP6TABLES,
 				 nf_call_ip6t);
 		} else if (matches(*argv, "nf_call_arptables") == 0) {
 			__u8 nf_call_arpt;
 
 			NEXT_ARG();
-			if (get_u8(&nf_call_arpt, *argv, 0)) {
+			if (get_u8(&nf_call_arpt, *argv, 0))
 				invarg("invalid nf_call_arptables", *argv);
-				return -1;
-			}
+
 			addattr8(n, 1024, IFLA_BR_NF_CALL_ARPTABLES,
 				 nf_call_arpt);
 		} else if (matches(*argv, "help") == 0) {
-- 
2.4.3
