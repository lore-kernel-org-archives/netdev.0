From: Phil Sutter <phil@nwl.cc>
Subject: [iproute PATCH 12/20] man: ip-netns.8: Clarify synopsis a bit
Date: Wed, 24 Feb 2016 09:21:25 +0100
Message-ID: <1456302093-697-13-git-send-email-phil@nwl.cc>
References: <1456302093-697-1-git-send-email-phil@nwl.cc>
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <shemming@brocade.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from orbyte.nwl.cc ([151.80.46.58]:45380 "EHLO mail.nwl.cc"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758073AbcBXIX1 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 24 Feb 2016 03:23:27 -0500
In-Reply-To: <1456302093-697-1-git-send-email-phil@nwl.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Use brackets to show that 'ip netns' defaults to action 'list', drop
superfluous curly braces around 'set' action keyword.

Signed-off-by: Phil Sutter <phil@nwl.cc>
---
 man/man8/ip-netns.8 | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/man/man8/ip-netns.8 b/man/man8/ip-netns.8
index c9b0fbc2c163d..c5310e24ed40b 100644
--- a/man/man8/ip-netns.8
+++ b/man/man8/ip-netns.8
@@ -13,7 +13,7 @@ ip-netns \- process network namespace management
 .BR help " }"
 .sp
 .ti -8
-.BR "ip netns" " { " list " } "
+.BR "ip netns" " [ " list " ]"
 
 .ti -8
 .B ip netns add
@@ -24,7 +24,7 @@ ip-netns \- process network namespace management
 .RI "[ " NETNSNAME " ]"
 
 .ti -8
-.BR "ip netns" " { " set " } "
+.B ip netns set
 .I NETNSNAME NETNSID
 
 .ti -8
-- 
2.6.4
