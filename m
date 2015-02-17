From: Matthew Thode <mthode@mthode.org>
Subject: [PATCH] colons are invalid characters in netdev names
Date: Tue, 17 Feb 2015 17:15:42 -0600
Message-ID: <1424214942-17581-1-git-send-email-mthode@mthode.org>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Matthew Thode <mthode@mthode.org>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 216-82-208-22.static.grandenetworks.net ([216.82.208.22]:39536
	"EHLO mx1.mthode.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753031AbbBQXQF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Feb 2015 18:16:05 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

colons are used as a separator in netdev device lookup in dev_ioctl.c

Specific functions are SIOCGIFTXQLEN SIOCETHTOOL SIOCSIFNAME

Signed-off-by: Matthew Thode <mthode@mthode.org>
---
 net/core/dev.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/core/dev.c b/net/core/dev.c
index d030575..e9b6d5a 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -942,7 +942,7 @@ bool dev_valid_name(const char *name)
 		return false;
 	if (strlen(name) >= IFNAMSIZ)
 		return false;
-	if (!strcmp(name, ".") || !strcmp(name, ".."))
+	if (!strcmp(name, ".") || !strcmp(name, "..") || !strcmp(name, ":"))
 		return false;
 
 	while (*name) {
-- 
2.0.5
