From: Phil Sutter <phil@nwl.cc>
Subject: [iproute PATCH] man: ip-route.8: Fix 'expires' indenting
Date: Thu,  2 Feb 2017 16:22:56 +0100
Message-ID: <20170202152256.25191-1-phil@nwl.cc>
Cc: Hangbin Liu <liuhangbin@gmail.com>, netdev@vger.kernel.org
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from orbyte.nwl.cc ([151.80.46.58]:58795 "EHLO mail.nwl.cc"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751147AbdBBPXC (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 2 Feb 2017 10:23:02 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Descriptions of each route sub-command's arguments are enclosed in
.RS/.RE pairs. For 'replace' sub-command, '.RE' was incorrectly put
before the last argument ('expires').

Fixes: 3fbe7ca847367 ("iproute2: ip-route.8.in: Add expires option for ip route")
Signed-off-by: Phil Sutter <phil@nwl.cc>
---
 man/man8/ip-route.8.in | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/man/man8/ip-route.8.in b/man/man8/ip-route.8.in
index 85191531b688c..d6e06649a4640 100644
--- a/man/man8/ip-route.8.in
+++ b/man/man8/ip-route.8.in
@@ -704,13 +704,13 @@ is a set of encapsulation attributes specific to the
 .sp
 
 .in -8
-.RE
 
 .TP
 .BI expires " TIME " "(4.4+ only)"
 the route will be deleted after the expires time.
 .B Only
 support IPv6 at present.
+.RE
 
 .TP
 ip route delete
-- 
2.11.0
