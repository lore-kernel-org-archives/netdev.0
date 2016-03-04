From: Phil Sutter <phil@nwl.cc>
Subject: [iproute PATCH 11/12] man: ship action man pages
Date: Fri,  4 Mar 2016 13:11:46 +0100
Message-ID: <1457093507-25601-12-git-send-email-phil@nwl.cc>
References: <1457093507-25601-1-git-send-email-phil@nwl.cc>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from orbyte.nwl.cc ([151.80.46.58]:52755 "EHLO mail.nwl.cc"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751466AbcCDMM4 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 4 Mar 2016 07:12:56 -0500
Received: from mail.nwl.cc (orbyte.nwl.cc [127.0.0.1])
	by mail.nwl.cc (Postfix) with ESMTP id DBDE26BF3E
	for <netdev@vger.kernel.org>; Fri,  4 Mar 2016 13:12:54 +0100 (CET)
Received: from xsao (localhost [IPv6:::1])
	by mail.nwl.cc (Postfix) with ESMTP id BFD0D6AF5C
	for <netdev@vger.kernel.org>; Fri,  4 Mar 2016 13:12:54 +0100 (CET)
In-Reply-To: <1457093507-25601-1-git-send-email-phil@nwl.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Phil Sutter <phil@nwl.cc>
---
 man/man8/Makefile | 4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

diff --git a/man/man8/Makefile b/man/man8/Makefile
index 2f77640676df5..d3fdf66ab11d4 100644
--- a/man/man8/Makefile
+++ b/man/man8/Makefile
@@ -14,7 +14,9 @@ MAN8PAGES = $(TARGETS) ip.8 arpd.8 lnstat.8 routel.8 rtacct.8 rtmon.8 rtpr.8 ss.
 	tipc.8 tipc-bearer.8 tipc-link.8 tipc-media.8 tipc-nametable.8 \
 	tipc-node.8 tipc-socket.8 \
 	tc-basic.8 tc-cgroup.8 tc-flow.8 tc-flower.8 tc-fw.8 tc-route.8 \
-	tc-tcindex.8 tc-u32.8
+	tc-tcindex.8 tc-u32.8 \
+	tc-connmark.8 tc-csum.8 tc-mirred.8 tc-nat.8 tc-pedit.8 tc-police.8 \
+	tc-simple.8 tc-skbedit.8 tc-vlan.8 tc-xt.8
 
 all: $(TARGETS)
 
-- 
2.7.2
