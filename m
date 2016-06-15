From: Phil Sutter <phil@nwl.cc>
Subject: [iproute PATCH v2 2/2] tc: m_action: Drop unused variable nladdr in tc_action_gd()
Date: Thu, 16 Jun 2016 00:50:39 +0200
Message-ID: <1466031039-18411-3-git-send-email-phil@nwl.cc>
References: <1466031039-18411-1-git-send-email-phil@nwl.cc>
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <shemming@brocade.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from orbyte.nwl.cc ([151.80.46.58]:53473 "EHLO mail.nwl.cc"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932235AbcFOWu6 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 15 Jun 2016 18:50:58 -0400
In-Reply-To: <1466031039-18411-1-git-send-email-phil@nwl.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This has been there since the introduction of tc/m_action.c back in 2004
and was apparently never in use.

Signed-off-by: Phil Sutter <phil@nwl.cc>
---
 tc/m_action.c | 4 ----
 1 file changed, 4 deletions(-)

diff --git a/tc/m_action.c b/tc/m_action.c
index f97ed2e775012..ea16817aefd4f 100644
--- a/tc/m_action.c
+++ b/tc/m_action.c
@@ -386,7 +386,6 @@ static int tc_action_gd(int cmd, unsigned int flags, int *argc_p, char ***argv_p
 	int prio = 0;
 	int ret = 0;
 	__u32 i;
-	struct sockaddr_nl nladdr;
 	struct rtattr *tail;
 	struct rtattr *tail2;
 	struct nlmsghdr *ans = NULL;
@@ -405,9 +404,6 @@ static int tc_action_gd(int cmd, unsigned int flags, int *argc_p, char ***argv_p
 		.buf = { 0 }
 	};
 
-	memset(&nladdr, 0, sizeof(nladdr));
-	nladdr.nl_family = AF_NETLINK;
-
 	argc -= 1;
 	argv += 1;
 
-- 
2.8.2
