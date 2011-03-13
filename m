From: Paul Gortmaker <paul.gortmaker@windriver.com>
Subject: [PATCH net-next 26/26] tipc: Update maintenance information
Date: Sun, 13 Mar 2011 17:34:14 -0400
Message-ID: <1300052054-7531-27-git-send-email-paul.gortmaker@windriver.com>
References: <1300052054-7531-1-git-send-email-paul.gortmaker@windriver.com>
Cc: netdev@vger.kernel.org, Allan.Stephens@windriver.com,
	Paul Gortmaker <paul.gortmaker@windriver.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:50026 "EHLO
	mail.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932259Ab1CMVfF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 13 Mar 2011 17:35:05 -0400
In-Reply-To: <1300052054-7531-1-git-send-email-paul.gortmaker@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Allan Stephens <Allan.Stephens@windriver.com>

Updates TIPC maintenance information to reflect changes that have
taken place during TIPC 2.0 development, including:

- removal of directories that have been deleted
- removal of websites that have been decommisioned
- removal of sidestream SCM repositories that are no longer used
- addition of netdev as appropriate list for kernel code.

Grateful acknowledgement is given to Joe Perches <joe@perches.com>,
who reported the stale file entry that triggered the update.

Signed-off-by: Allan Stephens <Allan.Stephens@windriver.com>
Signed-off-by: Paul Gortmaker <paul.gortmaker@windriver.com>
---
 MAINTAINERS |    6 ++----
 1 files changed, 2 insertions(+), 4 deletions(-)

diff --git a/MAINTAINERS b/MAINTAINERS
index 4765c67..a41c1e0 100644
--- a/MAINTAINERS
+++ b/MAINTAINERS
@@ -6083,13 +6083,11 @@ F:	sound/soc/codecs/twl4030*
 TIPC NETWORK LAYER
 M:	Jon Maloy <jon.maloy@ericsson.com>
 M:	Allan Stephens <allan.stephens@windriver.com>
-L:	tipc-discussion@lists.sourceforge.net
+L:	netdev@vger.kernel.org (core kernel code)
+L:	tipc-discussion@lists.sourceforge.net (user apps, general discussion)
 W:	http://tipc.sourceforge.net/
-W:	http://tipc.cslab.ericsson.net/
-T:	git git://tipc.cslab.ericsson.net/pub/git/tipc.git
 S:	Maintained
 F:	include/linux/tipc*.h
-F:	include/net/tipc/
 F:	net/tipc/
 
 TILE ARCHITECTURE
-- 
1.7.3.3

