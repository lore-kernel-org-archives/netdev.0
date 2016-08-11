From: Phil Sutter <phil@nwl.cc>
Subject: [iproute PATCH] man: ip-link.8: Document missing geneve options
Date: Fri, 12 Aug 2016 01:17:12 +0200
Message-ID: <1470957432-30855-1-git-send-email-phil@nwl.cc>
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from orbyte.nwl.cc ([151.80.46.58]:48868 "EHLO mail.nwl.cc"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751022AbcHKXRZ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 11 Aug 2016 19:17:25 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This adds missing documentation of geneve type options:

- dstport
- external
- udpcsum
- udp6zerocsumtx
- udp6zerocsumrx

The bits for the last three was just copy and pasted from vxlan section.

Signed-off-by: Phil Sutter <phil@nwl.cc>
---
 man/man8/ip-link.8.in | 36 ++++++++++++++++++++++++++++++++++++
 1 file changed, 36 insertions(+)

diff --git a/man/man8/ip-link.8.in b/man/man8/ip-link.8.in
index f4782ee5b8555..58247ced448df 100644
--- a/man/man8/ip-link.8.in
+++ b/man/man8/ip-link.8.in
@@ -801,6 +801,16 @@ the following additional arguments are supported:
 .BI tos " TOS "
 ] [
 .BI flowlabel " FLOWLABEL "
+] [
+.BI dstport " PORT"
+] [
+.RB [ no ] external
+] [
+.RB [ no ] udpcsum
+] [
+.RB [ no ] udp6zerocsumtx
+] [
+.RB [ no ] udp6zerocsumrx
 ]
 
 .in +8
@@ -824,6 +834,32 @@ the following additional arguments are supported:
 .BI flowlabel " FLOWLABEL"
 - specifies the flow label to use in outgoing packets.
 
+.sp
+.BI dstport " PORT"
+- select a destination port other than the default of 6081.
+
+.sp
+.RB [ no ] external
+- make this tunnel externally controlled (or not, which is the default). This
+flag is mutually exclusive with the
+.BR id ,
+.BR remote ,
+.BR ttl ,
+.BR tos " and " flowlabel
+options.
+
+.sp
+.RB [ no ] udpcsum
+- specifies if UDP checksum is calculated for transmitted packets over IPv4.
+
+.sp
+.RB [ no ] udp6zerocsumtx
+- skip UDP checksum calculation for transmitted packets over IPv6.
+
+.sp
+.RB [ no ] udp6zerocsumrx
+- allow incoming UDP packets over IPv6 with zero checksum field.
+
 .in -8
 
 .TP
-- 
2.8.2
