From: Simon Horman <simon.horman@netronome.com>
Subject: [PATCH iproute2/net-next] tc: flower: Update dest UDP port documentation
Date: Wed,  4 Jan 2017 12:02:18 +0100
Message-ID: <1483527738-22087-1-git-send-email-simon.horman@netronome.com>
Cc: netdev@vger.kernel.org,
        Dinan Gunawardena <dinan.gunawardena@netronome.com>,
        Hadar Hen Zion <hadarh@mellanox.com>,
        Simon Horman <simon.horman@netronome.com>
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f51.google.com ([74.125.82.51]:36089 "EHLO
        mail-wm0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751822AbdADLNS (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 4 Jan 2017 06:13:18 -0500
Received: by mail-wm0-f51.google.com with SMTP id c85so220050287wmi.1
        for <netdev@vger.kernel.org>; Wed, 04 Jan 2017 03:12:24 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Since 41aa17ff4668 ("tc/cls_flower: Add dest UDP port to tunnel params")
tc flower supports setting the dest UDP port.

* Use "port_number" to be consistent with other man-page text
* Re-add "enc_dst_port" documentation to manpage which was
  accidently removed by b2a1f740aa4d ("tc: flower: document that *_ip
  parameters take a PREFIX as an argument.")

Cc: Hadar Hen Zion <hadarh@mellanox.com>
Signed-off-by: Simon Horman <simon.horman@netronome.com>
---
 man/man8/tc-flower.8 | 4 +++-
 tc/f_flower.c        | 2 +-
 2 files changed, 4 insertions(+), 2 deletions(-)

diff --git a/man/man8/tc-flower.8 b/man/man8/tc-flower.8
index 33104963696c..5904a9ecafdf 100644
--- a/man/man8/tc-flower.8
+++ b/man/man8/tc-flower.8
@@ -40,7 +40,7 @@ flower \- flow based traffic control filter
 .BR enc_dst_ip " | " enc_src_ip " } { "
 .IR ipv4_address " | " ipv6_address " } | "
 .B enc_dst_port
-.IR UDP-PORT " | "
+.IR port_number
 .SH DESCRIPTION
 The
 .B flower
@@ -136,6 +136,8 @@ which have to be specified in beforehand.
 .BI enc_dst_ip " PREFIX"
 .TQ
 .BI enc_src_ip " PREFIX"
+.TQ
+.BI enc_dst_port " NUMBER"
 Match on IP tunnel metadata. Key id
 .I NUMBER
 is a 32 bit tunnel key id (e.g. VNI for VXLAN tunnel).
diff --git a/tc/f_flower.c b/tc/f_flower.c
index ba8b756b8a9e..99f5f8163ee0 100644
--- a/tc/f_flower.c
+++ b/tc/f_flower.c
@@ -58,7 +58,7 @@ static void explain(void)
 		"                       enc_src_ip [ IPV4-ADDR | IPV6-ADDR ] |\n"
 		"                       enc_key_id [ KEY-ID ] |\n"
 		"                       matching_flags MATCHING-FLAGS | \n"
-		"                       enc_dst_port [ UDP-PORT ] }\n"
+		"                       enc_dst_port [ port_number ] }\n"
 		"       FILTERID := X:Y:Z\n"
 		"       MASKED_LLADDR := { LLADDR | LLADDR/MASK | LLADDR/BITS }\n"
 		"       ACTION-SPEC := ... look at individual actions\n"
-- 
2.7.0.rc3.207.g0ac5344
