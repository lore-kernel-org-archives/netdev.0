From: David Ahern <dsa@cumulusnetworks.com>
Subject: [PATCH iproute2] man: ip-link: Add vrf type
Date: Tue, 21 Jun 2016 16:29:01 -0700
Message-ID: <1466551741-8090-1-git-send-email-dsa@cumulusnetworks.com>
Cc: stephen@networkplumber.org, David Ahern <dsa@cumulusnetworks.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f179.google.com ([209.85.192.179]:36411 "EHLO
	mail-pf0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751516AbcFVBQy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 21 Jun 2016 21:16:54 -0400
Received: by mail-pf0-f179.google.com with SMTP id t190so11865623pfb.3
        for <netdev@vger.kernel.org>; Tue, 21 Jun 2016 18:15:43 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add description for vrf type to ip-link man page.

Signed-off-by: David Ahern <dsa@cumulusnetworks.com>
---
 man/man8/ip-link.8.in | 20 +++++++++++++++++++-
 1 file changed, 19 insertions(+), 1 deletion(-)

diff --git a/man/man8/ip-link.8.in b/man/man8/ip-link.8.in
index d5673639d9dd..97042beaf4cc 100644
--- a/man/man8/ip-link.8.in
+++ b/man/man8/ip-link.8.in
@@ -65,7 +65,8 @@ ip-link \- network device configuration
 .BR nlmon " |"
 .BR ipvlan " |"
 .BR lowpan " |"
-.BR geneve " ]"
+.BR geneve " |"
+.BR vrf " ]"
 
 .ti -8
 .BR "ip link delete " {
@@ -263,6 +264,9 @@ specifies the type of the new device.
 .sp
 .BR macsec
 - Interface for IEEE 802.1AE MAC Security (MACsec)
+.sp
+.BR vrf
+- Interface for L3 VRF domains
 .in -8
 
 .TP
@@ -966,6 +970,20 @@ For a link of type
 
 .in -8
 
+.TP
+VRF Type Support
+For a link of type
+.I VRF
+the following additional arguments are supported:
+
+.BI "ip link add " DEVICE " type vrf table " TABLE
+
+.in +8
+.sp
+.BR table " table id associated with VRF device"
+
+.in -8
+
 .SS ip link delete - delete virtual link
 
 .TP
-- 
2.1.4
