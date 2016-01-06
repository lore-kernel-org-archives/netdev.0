From: Phil Sutter <phil@nwl.cc>
Subject: [iproute PATCH] tc: m_connmark: Fix help text
Date: Wed,  6 Jan 2016 17:46:50 +0100
Message-ID: <1452098810-4153-1-git-send-email-phil@nwl.cc>
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <shemming@brocade.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from orbyte.nwl.cc ([151.80.46.58]:60148 "EHLO mail.nwl.cc"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751761AbcAFQrF (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 6 Jan 2016 11:47:05 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When specifying a conntrack zone, the 'zone' keyword has to be used
before the actual zone index.

Signed-off-by: Phil Sutter <phil@nwl.cc>
---
 tc/m_connmark.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/tc/m_connmark.c b/tc/m_connmark.c
index 41ca4b25d4e90..6974c9ba6d16b 100644
--- a/tc/m_connmark.c
+++ b/tc/m_connmark.c
@@ -27,7 +27,7 @@
 static void
 explain(void)
 {
-	fprintf(stderr, "Usage: ... connmark [ZONE] [BRANCH] [index <INDEX>]\n");
+	fprintf(stderr, "Usage: ... connmark [zone ZONE] [BRANCH] [index <INDEX>]\n");
 	fprintf(stderr, "where :\n"
 		"\tZONE is the conntrack zone\n"
 		"\tBRANCH := reclassify|pipe|drop|continue|ok\n");
-- 
2.6.4
