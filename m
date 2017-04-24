From: Phil Sutter <phil@nwl.cc>
Subject: [iproute PATCH] man: ip-rule.8: Further clarify how to interpret priority value
Date: Mon, 24 Apr 2017 17:35:37 +0200
Message-ID: <20170424153537.15072-1-phil@nwl.cc>
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from orbyte.nwl.cc ([151.80.46.58]:36081 "EHLO mail.nwl.cc"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S964813AbdDXPfw (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 24 Apr 2017 11:35:52 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Despite the past changes, users seemed to get confused by the seemingly
contradictory relation of priority value and actual rule priority.

Signed-off-by: Phil Sutter <phil@nwl.cc>
---
 man/man8/ip-rule.8 | 8 ++++++--
 1 file changed, 6 insertions(+), 2 deletions(-)

diff --git a/man/man8/ip-rule.8 b/man/man8/ip-rule.8
index 7de80f3e6db9f..a5c479811927f 100644
--- a/man/man8/ip-rule.8
+++ b/man/man8/ip-rule.8
@@ -95,7 +95,10 @@ Each policy routing rule consists of a
 .B selector
 and an
 .B action predicate.
-The RPDB is scanned in order of decreasing priority. The selector
+The RPDB is scanned in order of decreasing priority (note that lower number
+means higher priority, see the description of
+.I PREFERENCE
+below). The selector
 of each rule is applied to {source address, destination address, incoming
 interface, tos, fwmark} and, if the selector matches the packet,
 the action is performed. The action predicate may return with success.
@@ -225,7 +228,8 @@ value to match.
 .BI priority " PREFERENCE"
 the priority of this rule.
 .I PREFERENCE
-is an unsigned integer value, higher number means lower priority.  Each rule
+is an unsigned integer value, higher number means lower priority, and rules get
+processed in order of increasing number. Each rule
 should have an explicitly set
 .I unique
 priority value.
-- 
2.11.0
