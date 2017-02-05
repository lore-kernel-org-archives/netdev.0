From: Yotam Gigi <yotamg@mellanox.com>
Subject: [PATCH iproute2/net-next 3/3] tc: man: matchall: Update examples to include sample
Date: Sun,  5 Feb 2017 09:58:54 +0200
Message-ID: <1486281534-61663-4-git-send-email-yotamg@mellanox.com>
References: <1486281534-61663-1-git-send-email-yotamg@mellanox.com>
Cc: Yotam Gigi <yotamg@mellanox.com>
To: stephen@networkplumber.org, netdev@vger.kernel.org,
        jiri@mellanox.com, eladr@mellanox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:55265 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1752142AbdBEH4p (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 5 Feb 2017 02:56:45 -0500
In-Reply-To: <1486281534-61663-1-git-send-email-yotamg@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add an example of packet sampling to the tc-matchall man page examples
section. The example uses the matchall classifier and the sample action to
create packet sampling on a port.

Reviewed-by: Jiri Pirko <jiri@mellanox.com>
Signed-off-by: Yotam Gigi <yotamg@mellanox.com>
---
 man/man8/tc-matchall.8 | 10 ++++++++++
 1 file changed, 10 insertions(+)

diff --git a/man/man8/tc-matchall.8 b/man/man8/tc-matchall.8
index f920922..799350a 100644
--- a/man/man8/tc-matchall.8
+++ b/man/man8/tc-matchall.8
@@ -70,6 +70,16 @@ that replaces the root qdisc on device
 where the second command attaches a matchall filters on it that mirrors the
 packets to device eth2.
 
+To sample one of every 100 packets flowing into interface eth0 to psample group
+12:
+.RS
+.EX
+
+tc qdisc add dev eth0 handle ffff: ingress
+tc filter add dev eth0 parent ffff: matchall \\
+     action sample rate 100 group 12
+.EE
+.RE
 
 .EE
 .SH SEE ALSO
-- 
2.4.11
