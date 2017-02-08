From: Simon Horman <simon.horman@netronome.com>
Subject: [PATCH iproute2/net-next repost] tc: flower: Update documentation to indicate ARP takes IPv4 prefixes
Date: Wed,  8 Feb 2017 13:01:04 +0100
Message-ID: <1486555264-18257-1-git-send-email-simon.horman@netronome.com>
Cc: Jiri Pirko <jiri@resnulli.us>,
        Dinan Gunawardena <dinan.gunawardena@netronome.com>,
        netdev@vger.kernel.org, oss-drivers@netronome.com,
        Simon Horman <simon.horman@netronome.com>
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f175.google.com ([209.85.128.175]:32988 "EHLO
        mail-wr0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932344AbdBHMBN (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 8 Feb 2017 07:01:13 -0500
Received: by mail-wr0-f175.google.com with SMTP id i10so59244581wrb.0
        for <netdev@vger.kernel.org>; Wed, 08 Feb 2017 04:01:12 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Unlike other PREFIXes documented in the usage for tc flower, which accept
both IPv4 and IPv6 prefixes, arp_sip and arp_tip only accepts IPv4
prefixes.

Signed-off-by: Simon Horman <simon.horman@netronome.com>
---
* Repost after breaking out of a larger patchset
---
 man/man8/tc-flower.8 | 8 ++++----
 tc/f_flower.c        | 4 ++--
 2 files changed, 6 insertions(+), 6 deletions(-)

diff --git a/man/man8/tc-flower.8 b/man/man8/tc-flower.8
index 2bdd2effd882..b1bef8b7637a 100644
--- a/man/man8/tc-flower.8
+++ b/man/man8/tc-flower.8
@@ -36,7 +36,7 @@ flower \- flow based traffic control filter
 .BR dst_port " | " src_port " } "
 .IR port_number " } | { "
 .BR arp_tip " | " arp_sip " } "
-.IR PREFIX " | "
+.IR IPV4_PREFIX " | "
 .BR arp_op " { " request " | " reply " | "
 .IR OP " } | { "
 .BR arp_tha " | " arp_sha " } "
@@ -139,11 +139,11 @@ Match on ICMP type or code. Only available for
 .BR ip_proto " values " icmp  " and " icmpv6
 which have to be specified in beforehand.
 .TP
-.BI arp_tip " PREFIX"
+.BI arp_tip " IPV4_PREFIX"
 .TQ
-.BI arp_sip " PREFIX"
+.BI arp_sip " IPV4_PREFIX"
 Match on ARP or RARP sender or target IP address.
-.I PREFIX
+.I IPV4_PREFIX
 must be a valid IPv4 address optionally followed by a slash and the prefix
 length. If the prefix is missing, \fBtc\fR assumes a full-length host
 match.
diff --git a/tc/f_flower.c b/tc/f_flower.c
index 403100c92af0..7cb2cd45a783 100644
--- a/tc/f_flower.c
+++ b/tc/f_flower.c
@@ -59,8 +59,8 @@ static void explain(void)
 		"                       src_port PORT-NUMBER |\n"
 		"                       type ICMP-TYPE |\n"
 		"                       code ICMP-CODE |\n"
-		"                       arp_tip PREFIX |\n"
-		"                       arp_sip PREFIX |\n"
+		"                       arp_tip IPV4-PREFIX |\n"
+		"                       arp_sip IPV4-PREFIX |\n"
 		"                       arp_op [ request | reply | OP ] |\n"
 		"                       arp_tha MASKED-LLADDR |\n"
 		"                       arp_sha MASKED-LLADDR |\n"
-- 
2.7.0.rc3.207.g0ac5344
