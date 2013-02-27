From: David Ward <david.ward@ll.mit.edu>
Subject: [PATCH iproute2] ip/iptunnel: Fix incorrect syntax in man page
Date: Wed, 27 Feb 2013 17:58:15 -0500
Message-ID: <1362005895-8460-1-git-send-email-david.ward@ll.mit.edu>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Andreas Henriksson <andreas@fatal.se>,
	David Ward <david.ward@ll.mit.edu>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from MX2.LL.MIT.EDU ([129.55.12.46]:37274 "EHLO mx2.ll.mit.edu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751991Ab3B0XXg (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 27 Feb 2013 18:23:36 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Reported-by: Andreas Henriksson <andreas@fatal.se>
Signed-off-by: David Ward <david.ward@ll.mit.edu>
---
 man/man8/ip-tunnel.8 |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/man/man8/ip-tunnel.8 b/man/man8/ip-tunnel.8
index b408517..3e558b0 100644
--- a/man/man8/ip-tunnel.8
+++ b/man/man8/ip-tunnel.8
@@ -60,9 +60,9 @@ ip-tunnel - tunnel configuration
 .IR TOS " := { " STRING " | " 00 ".." ff " |"
 .BR inherit " |"
 .BI "inherit/" STRING
-.R " |"
+.RB "|"
 .BI "inherit/" 00 ".." ff
-.R " }"
+.RB "}"
 
 .ti -8
 .IR ELIM " := {"
-- 
1.7.1
