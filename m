From: Phil Sutter <phil@nwl.cc>
Subject: [iproute PATCH 19/20] man: ip-l2tp.8: Fix BNF syntax
Date: Wed, 24 Feb 2016 09:21:32 +0100
Message-ID: <1456302093-697-20-git-send-email-phil@nwl.cc>
References: <1456302093-697-1-git-send-email-phil@nwl.cc>
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <shemming@brocade.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from orbyte.nwl.cc ([151.80.46.58]:51572 "EHLO mail.nwl.cc"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758117AbcBXIWn (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 24 Feb 2016 03:22:43 -0500
In-Reply-To: <1456302093-697-1-git-send-email-phil@nwl.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The 'ADDR' part of 'local' and 'remote' parameters is not optional, but
may also consist of the word 'any'. While at it, add missing whitespace
and fix fonts.

Signed-off-by: Phil Sutter <phil@nwl.cc>
---
 man/man8/ip-l2tp.8 | 24 +++++++++---------------
 1 file changed, 9 insertions(+), 15 deletions(-)

diff --git a/man/man8/ip-l2tp.8 b/man/man8/ip-l2tp.8
index 1738035f2400c..5b7041f93fc3d 100644
--- a/man/man8/ip-l2tp.8
+++ b/man/man8/ip-l2tp.8
@@ -15,10 +15,7 @@ ip-l2tp - L2TPv3 static unmanaged tunnel configuration
 .ti -8
 .BR "ip l2tp add tunnel"
 .br
-.B remote
-.RI "[ " ADDR " ]"
-.B local
-.RI "[ " ADDR " ]"
+.BI remote " ADDR " local " ADDR "
 .br
 .B tunnel_id
 .IR ID
@@ -73,24 +70,21 @@ ip-l2tp - L2TPv3 static unmanaged tunnel configuration
 .IR ID
 .br
 .ti -8
-.BR "ip l2tp show tunnel"
-.B "[" tunnel_id
-.IR ID
-.B "]"
+.BR "ip l2tp show tunnel" " [ " tunnel_id
+.IR ID " ]"
 .br
 .ti -8
-.BR "ip l2tp show session"
-.B "[" tunnel_id
-.IR ID
-.B "] [" session_id
-.IR ID
-.B "]"
+.BR "ip l2tp show session" " [ " tunnel_id
+.IR ID .B " ] ["
+.B session_id
+.IR ID " ]"
 .br
 .ti -8
 .IR NAME " := "
 .IR STRING
 .ti -8
-.IR ADDR " := { " IP_ADDRESS " }"
+.IR ADDR " := { " IP_ADDRESS " |"
+.BR any " }"
 .ti -8
 .IR PORT " := { " NUMBER " }"
 .ti -8
-- 
2.6.4
