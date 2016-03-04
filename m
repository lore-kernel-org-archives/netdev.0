From: Phil Sutter <phil@nwl.cc>
Subject: [iproute PATCH 4/5] man: ip-route: Make synopsis consistent with description
Date: Fri,  4 Mar 2016 12:52:40 +0100
Message-ID: <1457092361-17603-5-git-send-email-phil@nwl.cc>
References: <1457092361-17603-1-git-send-email-phil@nwl.cc>
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <shemming@brocade.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from orbyte.nwl.cc ([151.80.46.58]:55209 "EHLO mail.nwl.cc"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751112AbcCDLwy (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 4 Mar 2016 06:52:54 -0500
In-Reply-To: <1457092361-17603-1-git-send-email-phil@nwl.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

While the synopsis section contains 'ip route list', it is later
described as 'ip route show'. Make this consistent by replacing 'list'
with 'show' in synopsis.

Signed-off-by: Phil Sutter <phil@nwl.cc>
---
 man/man8/ip-route.8.in | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/man/man8/ip-route.8.in b/man/man8/ip-route.8.in
index c764bfc8ead86..d7fb8fba8bb05 100644
--- a/man/man8/ip-route.8.in
+++ b/man/man8/ip-route.8.in
@@ -16,7 +16,7 @@ ip-route \- routing table management
 
 .ti -8
 .BR "ip route" " { "
-.BR list " | " flush " } "
+.BR show " | " flush " } "
 .I  SELECTOR
 
 .ti -8
-- 
2.7.2
