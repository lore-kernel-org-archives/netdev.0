From: Phil Sutter <phil@nwl.cc>
Subject: [iproute PATCH] man: ip-route.8: Add notes about dropped IPv4 route cache
Date: Wed, 30 Nov 2016 09:29:48 +0100
Message-ID: <20161130082948.21925-1-phil@nwl.cc>
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from orbyte.nwl.cc ([151.80.46.58]:34862 "EHLO mail.nwl.cc"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753042AbcK3IaA (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 30 Nov 2016 03:30:00 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Phil Sutter <phil@nwl.cc>
---
 man/man8/ip-route.8.in | 6 ++++++
 1 file changed, 6 insertions(+)

diff --git a/man/man8/ip-route.8.in b/man/man8/ip-route.8.in
index d4fae3cc783ba..c0acaa0020ef7 100644
--- a/man/man8/ip-route.8.in
+++ b/man/man8/ip-route.8.in
@@ -924,6 +924,12 @@ routes are left unchanged. Any routes specified in the data stream that
 already exist in the table will be ignored.
 .RE
 
+.SH NOTES
+Starting with Linux kernel version 3.6, there is no routing cache for IPv4
+anymore. Hence
+.B "ip route show cached"
+will never print any entries on systems with this or newer kernel versions.
+
 .SH EXAMPLES
 .PP
 ip ro
-- 
2.10.0
