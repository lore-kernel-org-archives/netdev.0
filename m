From: Phil Sutter <phil@nwl.cc>
Subject: [iproute PATCH] man: tc-csum.8: Fix example
Date: Fri, 27 Jan 2017 12:15:01 +0100
Message-ID: <20170127111501.21439-1-phil@nwl.cc>
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from orbyte.nwl.cc ([151.80.46.58]:43087 "EHLO mail.nwl.cc"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S933369AbdA0LPY (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 27 Jan 2017 06:15:24 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This fixes two issues with the provided example:

- Add missing 'dev' keyword to second command.
- Use a real IPv4 address instead of a bogus hex value since that will
  be rejected by get_addr_ipv4().

Fixes: dbfb17a67f9c7 ("man: tc-csum.8: Add an example")
Reported-by: Davide Caratti <dcaratti@redhat.com>
Signed-off-by: Phil Sutter <phil@nwl.cc>
---
 man/man8/tc-csum.8 | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/man/man8/tc-csum.8 b/man/man8/tc-csum.8
index 3a64c82f09ba8..43561d9f90a8e 100644
--- a/man/man8/tc-csum.8
+++ b/man/man8/tc-csum.8
@@ -57,9 +57,9 @@ packets, both IP and UDP checksums have to be recalculated:
 .RS
 .EX
 # tc qdisc add dev eth0 ingress handle ffff:
-# tc filter add eth0 prio 1 protocol ip parent ffff: \\
+# tc filter add dev eth0 prio 1 protocol ip parent ffff: \\
 	u32 match ip src 192.168.1.100/32 flowid :1 \\
-	action pedit munge ip dst set 0x12345678 pipe \\
+	action pedit munge ip dst set 1.2.3.4 pipe \\
 	csum ip and udp
 .EE
 .RE
-- 
2.11.0
