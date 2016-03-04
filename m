From: Phil Sutter <phil@nwl.cc>
Subject: [iproute PATCH 1/5] tc: pedit: document branch control in help output
Date: Fri,  4 Mar 2016 12:52:37 +0100
Message-ID: <1457092361-17603-2-git-send-email-phil@nwl.cc>
References: <1457092361-17603-1-git-send-email-phil@nwl.cc>
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <shemming@brocade.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from orbyte.nwl.cc ([151.80.46.58]:56939 "EHLO mail.nwl.cc"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752112AbcCDLxT (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 4 Mar 2016 06:53:19 -0500
In-Reply-To: <1457092361-17603-1-git-send-email-phil@nwl.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This seems to have been a hidden feature, though it's very useful and
necessary at least when combining multiple pedit actions.

Signed-off-by: Phil Sutter <phil@nwl.cc>
---
 tc/m_pedit.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/tc/m_pedit.c b/tc/m_pedit.c
index 4fdd189d7d9c6..86eb0ca3fbb38 100644
--- a/tc/m_pedit.c
+++ b/tc/m_pedit.c
@@ -35,7 +35,7 @@ static int pedit_debug;
 static void
 explain(void)
 {
-	fprintf(stderr, "Usage: ... pedit munge <MUNGE>\n");
+	fprintf(stderr, "Usage: ... pedit munge <MUNGE> [<BRANCH>]\n");
 	fprintf(stderr,
 		"Where: MUNGE := <RAW>|<LAYERED>\n"
 		"\t<RAW>:= <OFFSETC>[ATC]<CMD>\n "
@@ -47,6 +47,7 @@ explain(void)
 		"\t\tCMD:= clear | invert | set <setval>| retain\n "
 		"\t<LAYERED>:= ip <ipdata> | ip6 <ip6data> \n "
 		" \t\t| udp <udpdata> | tcp <tcpdata> | icmp <icmpdata> \n"
+		"\t<BRANCH>:= reclassify | pipe | drop | continue | pass\n"
 		"For Example usage look at the examples directory\n");
 
 }
-- 
2.7.2
