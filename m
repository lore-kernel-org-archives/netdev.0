From: esr@thyrsus.com (Eric S. Raymond)
Subject: [PATCH] ip-rule.8: Fix presentational use of .SS.
Date: Wed, 10 Jul 2013 00:49:35 -0400 (EDT)
Message-ID: <20130710044935.7E22943797@snark.thyrsus.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from static-71-162-243-5.phlapa.fios.verizon.net ([71.162.243.5]:49683
	"EHLO snark.thyrsus.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751247Ab3GJEtl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Jul 2013 00:49:41 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

---
 man/man8/ip-rule.8 | 21 ++++++++++++---------
 1 file changed, 12 insertions(+), 9 deletions(-)

diff --git a/man/man8/ip-rule.8 b/man/man8/ip-rule.8
index 36f461b..36e46f1 100644
--- a/man/man8/ip-rule.8
+++ b/man/man8/ip-rule.8
@@ -140,7 +140,7 @@ are only used if the route did not select any attributes.
 .sp
 The RPDB may contain rules of the following types:
 
-.in +8
+.RS
 .B unicast
 - the rule prescribes to return the route found
 in the routing table referenced by the rule.
@@ -158,12 +158,14 @@ prohibited' error.
 .B nat
 - the rule prescribes to translate the source address
 of the IP packet into some other value.
-.in -8
-
-.SS ip rule add - insert a new rule
-.SS ip rule delete - delete a rule
+.RE
 
 .TP
+.B ip rule add - insert a new rule
+.TP
+.B ip rule delete - delete a rule
+.RS
+.TP
 .BI type " TYPE " (default)
 the type of this rule.  The list of valid types was given in the previous
 subsection.
@@ -237,11 +239,12 @@ Changes to the RPDB made with these commands do not become active
 immediately.  It is assumed that after a script finishes a batch of
 updates, it flushes the routing cache with
 .BR "ip route flush cache" .
-
-.SS ip rule flush - also dumps all the deleted rules.
+.RE
+.TP
+.B ip rule flush - also dumps all the deleted rules.
 This command has no arguments.
-
-.SS ip rule show - list rules
+.TP
+.B ip rule show - list rules
 This command has no arguments.
 The options list or lst are synonyms with show.
 
-- 
1.8.0.1.g2b06c9a



-- 
		<a href="http://www.catb.org/~esr/">Eric S. Raymond</a>

I do not find in orthodox Christianity one redeeming feature.
	-- Thomas Jefferson
