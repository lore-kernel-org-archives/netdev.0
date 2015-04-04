From: Vadim Kochan <vadim4j@gmail.com>
Subject: [PATCH iproute2] man ip-link: Add missing link types - vti,ipvlan,nlmon
Date: Sat,  4 Apr 2015 19:00:55 +0300
Message-ID: <1428163255-1509-1-git-send-email-vadim4j@gmail.com>
Cc: Vadim Kochan <vadim4j@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f170.google.com ([209.85.212.170]:32863 "EHLO
	mail-wi0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752244AbbDDQM6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 4 Apr 2015 12:12:58 -0400
Received: by wiax7 with SMTP id x7so409499wia.0
        for <netdev@vger.kernel.org>; Sat, 04 Apr 2015 09:12:57 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Vadim Kochan <vadim4j@gmail.com>

Signed-off-by: Vadim Kochan <vadim4j@gmail.com>
---
 man/man8/ip-link.8.in | 14 +++++++++++++-
 1 file changed, 13 insertions(+), 1 deletion(-)

diff --git a/man/man8/ip-link.8.in b/man/man8/ip-link.8.in
index 0e3bb5e..642cdb2 100644
--- a/man/man8/ip-link.8.in
+++ b/man/man8/ip-link.8.in
@@ -72,7 +72,10 @@ ip-link \- network device configuration
 .BR gre " |"
 .BR gretap " |"
 .BR ip6gre " |"
-.BR ip6gretap " ]"
+.BR ip6gretap " |"
+.BR vti " |"
+.BR nlmon " |"
+.BR ipvlan " ]"
 
 .ti -8
 .BI "ip link delete " DEVICE
@@ -228,6 +231,15 @@ Link types:
 .sp
 .BR ip6gretap
 - Virtual L2 tunnel interface GRE over IPv6
+.sp
+.BR vti
+- Virtual tunnel interface
+.sp
+.BR nlmon
+- Netlink monitoring device
+.sp
+.BR ipvlan
+- Interface for L3 (IPv6/IPv4) based VLANs
 .in -8
 
 .TP
-- 
2.3.1
