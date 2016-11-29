From: Simon Horman <simon.horman@netronome.com>
Subject: [PATCH iproute2 net-next 1/4] tc: flower: remove references to eth_type in manpage
Date: Tue, 29 Nov 2016 16:51:30 +0100
Message-ID: <1480434693-29397-2-git-send-email-simon.horman@netronome.com>
References: <1480434693-29397-1-git-send-email-simon.horman@netronome.com>
Cc: netdev@vger.kernel.org, Simon Horman <simon.horman@netronome.com>,
        Paul Blakey <paulb@mellanox.com>
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f53.google.com ([74.125.82.53]:38269 "EHLO
        mail-wm0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S934050AbcK2PwM (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 29 Nov 2016 10:52:12 -0500
Received: by mail-wm0-f53.google.com with SMTP id f82so192514601wmf.1
        for <netdev@vger.kernel.org>; Tue, 29 Nov 2016 07:52:11 -0800 (PST)
In-Reply-To: <1480434693-29397-1-git-send-email-simon.horman@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Remove references to eth_type and ether_type (spelling error) in
the tc flower manpage.

Also correct formatting of boldface text with whitespace.

Cc: Paul Blakey <paulb@mellanox.com>
Signed-off-by: Simon Horman <simon.horman@netronome.com>
---
This is a follow-up to "tc: flower: Fix usage message"
---
 man/man8/tc-flower.8 | 23 +++++++++++------------
 1 file changed, 11 insertions(+), 12 deletions(-)

diff --git a/man/man8/tc-flower.8 b/man/man8/tc-flower.8
index 16ef261797ab..56db42f983c1 100644
--- a/man/man8/tc-flower.8
+++ b/man/man8/tc-flower.8
@@ -103,8 +103,8 @@ or an unsigned 8bit value in hexadecimal format.
 Match on source or destination IP address.
 .I ADDRESS
 must be a valid IPv4 or IPv6 address, depending on
-.BR ether_type ,
-which has to be specified in beforehand.
+.BR protocol
+option of tc filter.
 .TP
 .BI dst_port " NUMBER"
 .TQ
@@ -114,16 +114,15 @@ Match on layer 4 protocol source or destination port number. Only available for
 which has to be specified in beforehand.
 .SH NOTES
 As stated above where applicable, matches of a certain layer implicitly depend
-on the matches of the next lower layer. Precisely, layer one and two matches (
-.BR indev , dst_mac , src_mac " and " eth_type )
-have no dependency, layer three matches (
-.BR ip_proto , dst_ip " and " src_ip )
-require
-.B eth_type
-being set to either
-.BR ipv4 " or " ipv6 ,
-and finally layer four matches (
-.BR dst_port " and " src_port )
+on the matches of the next lower layer. Precisely, layer one and two matches
+(\fBindev\fR,  \fBdst_mac\fR and \fBsrc_mac\fR)
+have no dependency, layer three matches
+(\fBip_proto\fR, \fBdst_ip\fR and \fBsrc_ip\fR)
+depend on the
+.B protocol
+option of tc filter
+and finally layer four matches
+(\fBdst_port\fR and \fBsrc_port\fR)
 depend on
 .B ip_proto
 being set to either
-- 
2.7.0.rc3.207.g0ac5344
