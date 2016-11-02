From: Paul Blakey <paulb@mellanox.com>
Subject: [PATCH iproute2] tc: flower: Fix usage message
Date: Wed,  2 Nov 2016 17:09:58 +0200
Message-ID: <1478099398-21639-1-git-send-email-paulb@mellanox.com>
Cc: Or Gerlitz <ogerlitz@mellanox.com>,
        Paul Blakey <paulb@mellanox.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:43834 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1752592AbcKBPKL (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 2 Nov 2016 11:10:11 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Remove left over usage from removal of eth_type argument.

Fixes: 488b41d020fb ('tc: flower no need to specify the ethertype')
Signed-off-by: Paul Blakey <paulb@mellanox.com>
---
 man/man8/tc-flower.8 | 9 ---------
 tc/f_flower.c        | 3 +--
 2 files changed, 1 insertion(+), 11 deletions(-)

diff --git a/man/man8/tc-flower.8 b/man/man8/tc-flower.8
index 74f7664..16ef261 100644
--- a/man/man8/tc-flower.8
+++ b/man/man8/tc-flower.8
@@ -23,8 +23,6 @@ flower \- flow based traffic control filter
 .R " | { "
 .BR dst_mac " | " src_mac " } "
 .IR mac_address " | "
-.BR eth_type " { " ipv4 " | " ipv6 " | " 802.1Q " | "
-.IR ETH_TYPE " } | "
 .B vlan_id
 .IR VID " | "
 .B vlan_prio
@@ -75,13 +73,6 @@ Do not process filter by hardware.
 .BI src_mac " mac_address"
 Match on source or destination MAC address.
 .TP
-.BI eth_type " ETH_TYPE"
-Match on the next protocol.
-.I ETH_TYPE
-may be either
-.BR ipv4 , ipv6 , 802.1Q ,
-or an unsigned 16bit value in hexadecimal format.
-.TP
 .BI vlan_id " VID"
 Match on vlan tag id.
 .I VID
diff --git a/tc/f_flower.c b/tc/f_flower.c
index 2d31d1a..f39b1f7 100644
--- a/tc/f_flower.c
+++ b/tc/f_flower.c
@@ -36,7 +36,6 @@ static void explain(void)
 	fprintf(stderr, "                       vlan_ethtype [ ipv4 | ipv6 | ETH-TYPE ] |\n");
 	fprintf(stderr, "                       dst_mac MAC-ADDR |\n");
 	fprintf(stderr, "                       src_mac MAC-ADDR |\n");
-	fprintf(stderr, "                       [ipv4 | ipv6 ] |\n");
 	fprintf(stderr, "                       ip_proto [tcp | udp | IP-PROTO ] |\n");
 	fprintf(stderr, "                       dst_ip [ IPV4-ADDR | IPV6-ADDR ] |\n");
 	fprintf(stderr, "                       src_ip [ IPV4-ADDR | IPV6-ADDR ] |\n");
@@ -45,7 +44,7 @@ static void explain(void)
 	fprintf(stderr,	"       FILTERID := X:Y:Z\n");
 	fprintf(stderr,	"       ACTION-SPEC := ... look at individual actions\n");
 	fprintf(stderr,	"\n");
-	fprintf(stderr,	"NOTE: CLASSID, ETH-TYPE, IP-PROTO are parsed as hexadecimal input.\n");
+	fprintf(stderr,	"NOTE: CLASSID, IP-PROTO are parsed as hexadecimal input.\n");
 	fprintf(stderr,	"NOTE: There can be only used one mask per one prio. If user needs\n");
 	fprintf(stderr,	"      to specify different mask, he has to use different prio.\n");
 }
-- 
1.8.3.1
