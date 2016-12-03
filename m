From: Simon Horman <simon.horman@netronome.com>
Subject: [PATCH iproute2/net-next v3 1/3] tc: flower: document SCTP ip_proto
Date: Sat,  3 Dec 2016 09:52:38 +0100
Message-ID: <1480755160-27768-2-git-send-email-simon.horman@netronome.com>
References: <1480755160-27768-1-git-send-email-simon.horman@netronome.com>
Cc: netdev@vger.kernel.org, Simon Horman <simon.horman@netronome.com>
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f54.google.com ([74.125.82.54]:37481 "EHLO
        mail-wm0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751817AbcLCIxA (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 3 Dec 2016 03:53:00 -0500
Received: by mail-wm0-f54.google.com with SMTP id t79so34767036wmt.0
        for <netdev@vger.kernel.org>; Sat, 03 Dec 2016 00:52:51 -0800 (PST)
In-Reply-To: <1480755160-27768-1-git-send-email-simon.horman@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add SCTP ip_proto to help text and man page.

Signed-off-by: Simon Horman <simon.horman@netronome.com>
---
 man/man8/tc-flower.8 | 14 +++++++-------
 tc/f_flower.c        |  2 +-
 2 files changed, 8 insertions(+), 8 deletions(-)

diff --git a/man/man8/tc-flower.8 b/man/man8/tc-flower.8
index 11cf774dd7de..744c450b4531 100644
--- a/man/man8/tc-flower.8
+++ b/man/man8/tc-flower.8
@@ -29,7 +29,7 @@ flower \- flow based traffic control filter
 .IR PRIORITY " | "
 .BR vlan_eth_type " { " ipv4 " | " ipv6 " | "
 .IR ETH_TYPE " } | "
-.BR ip_proto " { " tcp " | " udp " | "
+.BR ip_proto " { " tcp " | " udp " | " sctp " | "
 .IR IP_PROTO " } | { "
 .BR dst_ip " | " src_ip " } { "
 .IR ipv4_address " | " ipv6_address " } | { "
@@ -97,8 +97,8 @@ or an unsigned 16bit value in hexadecimal format.
 .BI ip_proto " IP_PROTO"
 Match on layer four protocol.
 .I IP_PROTO
-may be either
-.BR tcp , udp
+may be
+.BR tcp ", " udp ", " sctp
 or an unsigned 8bit value in hexadecimal format.
 .TP
 .BI dst_ip " ADDRESS"
@@ -114,8 +114,8 @@ option of tc filter.
 .TQ
 .BI src_port " NUMBER"
 Match on layer 4 protocol source or destination port number. Only available for
-.BR ip_proto " values " udp " and " tcp ,
-which has to be specified in beforehand.
+.BR ip_proto " values " udp ", " tcp  " and " sctp
+which have to be specified in beforehand.
 .TP
 .BI enc_key_id " NUMBER"
 .TQ
@@ -140,8 +140,8 @@ and finally layer four matches
 (\fBdst_port\fR and \fBsrc_port\fR)
 depend on
 .B ip_proto
-being set to either
-.BR tcp " or " udp .
+being set to
+.BR tcp ", " udp " or " sctp.
 .P
 There can be only used one mask per one prio. If user needs to specify different
 mask, he has to use different prio.
diff --git a/tc/f_flower.c b/tc/f_flower.c
index 7e7f4c92a947..f04c594d06ae 100644
--- a/tc/f_flower.c
+++ b/tc/f_flower.c
@@ -37,7 +37,7 @@ static void explain(void)
 		"                       vlan_ethtype [ ipv4 | ipv6 | ETH-TYPE ] |\n"
 		"                       dst_mac MAC-ADDR |\n"
 		"                       src_mac MAC-ADDR |\n"
-		"                       ip_proto [tcp | udp | IP-PROTO ] |\n"
+		"                       ip_proto [tcp | udp | sctp | IP-PROTO ] |\n"
 		"                       dst_ip [ IPV4-ADDR | IPV6-ADDR ] |\n"
 		"                       src_ip [ IPV4-ADDR | IPV6-ADDR ] |\n"
 		"                       dst_port PORT-NUMBER |\n"
-- 
2.7.0.rc3.207.g0ac5344
