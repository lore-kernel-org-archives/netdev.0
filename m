From: Phil Sutter <phil@nwl.cc>
Subject: [iproute PATCH 14/20] man: ip-rule.8: Review synopsis section
Date: Wed, 24 Feb 2016 09:21:27 +0100
Message-ID: <1456302093-697-15-git-send-email-phil@nwl.cc>
References: <1456302093-697-1-git-send-email-phil@nwl.cc>
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <shemming@brocade.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from orbyte.nwl.cc ([151.80.46.58]:52852 "EHLO mail.nwl.cc"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758117AbcBXIWg (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 24 Feb 2016 03:22:36 -0500
In-Reply-To: <1456302093-697-1-git-send-email-phil@nwl.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Clarify that 'ip rule' defaults to action 'list', that 'flush' and
'save' actions don't accept additional parameters, add missing 'not' and
'goto' keywords and finally fix fonts used in 'fwmark' and 'realms'
parameters.

Signed-off-by: Phil Sutter <phil@nwl.cc>
---
 man/man8/ip-rule.8 | 19 +++++++++++++------
 1 file changed, 13 insertions(+), 6 deletions(-)

diff --git a/man/man8/ip-rule.8 b/man/man8/ip-rule.8
index b7008c6ab13d7..e9fbb3cf1a62d 100644
--- a/man/man8/ip-rule.8
+++ b/man/man8/ip-rule.8
@@ -9,20 +9,26 @@ ip-rule \- routing policy database management
 .B ip
 .RI "[ " OPTIONS " ]"
 .B rule
-.RI " { " COMMAND " | "
+.RI "{ " COMMAND " | "
 .BR help " }"
 .sp
 
 .ti -8
 .B  ip rule
-.RB " [ " list " | " add " | " del " | " flush " | " save " ]"
+.RB "[ " list " ]"
+
+.ti -8
+.B  ip rule
+.RB "{ " add " | " del " }"
 .I  SELECTOR ACTION
 
 .ti -8
-.B  ip rule  " restore "
+.B ip rule
+.RB "{ " flush " | " save " | " restore " }"
 
 .ti -8
 .IR SELECTOR " := [ "
+.BR not " ] ["
 .B  from
 .IR PREFIX " ] [ "
 .B  to
@@ -30,7 +36,7 @@ ip-rule \- routing policy database management
 .B  tos
 .IR TOS " ] [ "
 .B  fwmark
-.IR FWMARK[/MASK] " ] [ "
+.IR FWMARK\fR[\fB/\fIMASK "] ] [ "
 .B  iif
 .IR STRING " ] [ "
 .B  oif
@@ -45,8 +51,9 @@ ip-rule \- routing policy database management
 .B  nat
 .IR ADDRESS " ] [ "
 .B realms
-.RI "[" SRCREALM "/]" DSTREALM " ]"
-.I  SUPPRESSOR
+.RI "[" SRCREALM "\fB/\fR]" DSTREALM " ] ["
+.B goto
+.IR NUMBER " ] " SUPPRESSOR
 
 .ti -8
 .IR SUPPRESSOR " := [ "
-- 
2.6.4
