From: Phil Sutter <phil@nwl.cc>
Subject: [iproute PATCH 11/20] man: ip-neighbour: Fix for missing NUD_STATE description
Date: Wed, 24 Feb 2016 09:21:24 +0100
Message-ID: <1456302093-697-12-git-send-email-phil@nwl.cc>
References: <1456302093-697-1-git-send-email-phil@nwl.cc>
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <shemming@brocade.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from orbyte.nwl.cc ([151.80.46.58]:45640 "EHLO mail.nwl.cc"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757932AbcBXIWE (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 24 Feb 2016 03:22:04 -0500
In-Reply-To: <1456302093-697-1-git-send-email-phil@nwl.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Phil Sutter <phil@nwl.cc>
---
 man/man8/ip-neighbour.8 | 11 ++++++++---
 1 file changed, 8 insertions(+), 3 deletions(-)

diff --git a/man/man8/ip-neighbour.8 b/man/man8/ip-neighbour.8
index c9b0256e12207..19c6d9d8bf605 100644
--- a/man/man8/ip-neighbour.8
+++ b/man/man8/ip-neighbour.8
@@ -18,7 +18,9 @@ ip-neighbour \- neighbour/arp tables management.
 .IR ADDR " [ "
 .B  lladdr
 .IR LLADDR " ] [ "
-.BR nud " { " permanent " | " noarp " | " stale " | " reachable " } ] | " proxy
+.B nud
+.IR STATE " ] |"
+.B proxy
 .IR ADDR " } [ "
 .B  dev
 .IR DEV " ]"
@@ -31,6 +33,9 @@ ip-neighbour \- neighbour/arp tables management.
 .B  nud
 .IR STATE " ]"
 
+.ti -8
+.IR STATE " := {"
+.BR permanent " | " noarp " | " stale " | " reachable " }"
 
 .SH DESCRIPTION
 The
@@ -75,7 +80,7 @@ can also be
 .BR "null" .
 
 .TP
-.BI nud " NUD_STATE"
+.BI nud " STATE"
 the state of the neighbour entry.
 .B nud
 is an abbreviation for 'Neighbour Unreachability Detection'.
@@ -147,7 +152,7 @@ list neighbour proxies.
 only list neighbours which are not currently in use.
 
 .TP
-.BI nud " NUD_STATE"
+.BI nud " STATE"
 only list neighbour entries in this state.
 .I NUD_STATE
 takes values listed below or the special value
-- 
2.6.4
