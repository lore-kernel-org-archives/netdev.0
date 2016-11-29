From: Simon Horman <simon.horman@netronome.com>
Subject: [PATCH iproute2 net-next 2/4] tc: flower: document SCTP ip_proto
Date: Tue, 29 Nov 2016 16:51:31 +0100
Message-ID: <1480434693-29397-3-git-send-email-simon.horman@netronome.com>
References: <1480434693-29397-1-git-send-email-simon.horman@netronome.com>
Cc: netdev@vger.kernel.org, Simon Horman <simon.horman@netronome.com>
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f43.google.com ([74.125.82.43]:35008 "EHLO
        mail-wm0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S934057AbcK2PwR (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 29 Nov 2016 10:52:17 -0500
Received: by mail-wm0-f43.google.com with SMTP id a197so241550565wmd.0
        for <netdev@vger.kernel.org>; Tue, 29 Nov 2016 07:52:16 -0800 (PST)
In-Reply-To: <1480434693-29397-1-git-send-email-simon.horman@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add SCTP ip_proto to help text and man page.

Signed-off-by: Simon Horman <simon.horman@netronome.com>
---
This a follow-up to ("tc: flower: Support matching on SCTP ports")
---
 man/man8/tc-flower.8 | 14 +++++++-------
 tc/f_flower.c        |  2 +-
 2 files changed, 8 insertions(+), 8 deletions(-)

diff --git a/man/man8/tc-flower.8 b/man/man8/tc-flower.8
index 56db42f983c1..a401293fed50 100644
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
@@ -93,8 +93,8 @@ or an unsigned 16bit value in hexadecimal format.
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
@@ -110,8 +110,8 @@ option of tc filter.
 .TQ
 .BI src_port " NUMBER"
 Match on layer 4 protocol source or destination port number. Only available for
-.BR ip_proto " values " udp " and " tcp ,
-which has to be specified in beforehand.
+.BR ip_proto " values " udp ", " tcp  " and " sctp
+which have to be specified in beforehand.
 .SH NOTES
 As stated above where applicable, matches of a certain layer implicitly depend
 on the matches of the next lower layer. Precisely, layer one and two matches
@@ -125,8 +125,8 @@ and finally layer four matches
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
index d1694623863d..c74a0244e244 100644
--- a/tc/f_flower.c
+++ b/tc/f_flower.c
@@ -36,7 +36,7 @@ static void explain(void)
 	fprintf(stderr, "                       vlan_ethtype [ ipv4 | ipv6 | ETH-TYPE ] |\n");
 	fprintf(stderr, "                       dst_mac MAC-ADDR |\n");
 	fprintf(stderr, "                       src_mac MAC-ADDR |\n");
-	fprintf(stderr, "                       ip_proto [tcp | udp | IP-PROTO ] |\n");
+	fprintf(stderr, "                       ip_proto [ tcp | udp | sctp | IP-PROTO ] |\n");
 	fprintf(stderr, "                       dst_ip [ IPV4-ADDR | IPV6-ADDR ] |\n");
 	fprintf(stderr, "                       src_ip [ IPV4-ADDR | IPV6-ADDR ] |\n");
 	fprintf(stderr, "                       dst_port PORT-NUMBER |\n");
-- 
2.7.0.rc3.207.g0ac5344
