From: Phil Sutter <phil@nwl.cc>
Subject: [iproute PATCH 2/2] tc: m_action: Drop unused variable nladdr in tc_action_gd()
Date: Wed, 15 Jun 2016 00:26:09 +0200
Message-ID: <1465943169-4101-3-git-send-email-phil@nwl.cc>
References: <1465943169-4101-1-git-send-email-phil@nwl.cc>
Cc: netdev@vger.kernel.org, Phil Sutter <psutter@redhat.com>
To: Stephen Hemminger <shemming@brocade.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from orbyte.nwl.cc ([151.80.46.58]:33896 "EHLO mail.nwl.cc"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751113AbcFNW03 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 14 Jun 2016 18:26:29 -0400
In-Reply-To: <1465943169-4101-1-git-send-email-phil@nwl.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Phil Sutter <psutter@redhat.com>

This has been there since the introduction of tc/m_action.c back in 2004
and was apparently never in use.

Signed-off-by: Phil Sutter <phil@nwl.cc>
---
 tc/m_action.c | 4 ----
 1 file changed, 4 deletions(-)

diff --git a/tc/m_action.c b/tc/m_action.c
index 1b34370f4ec09..fd324090db1f2 100644
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
@@ -400,9 +399,6 @@ static int tc_action_gd(int cmd, unsigned int flags, int *argc_p, char ***argv_p
 	memset(&req, 0, sizeof(req));
 	req.t.tca_family = AF_UNSPEC;
 
-	memset(&nladdr, 0, sizeof(nladdr));
-	nladdr.nl_family = AF_NETLINK;
-
 	req.n.nlmsg_len = NLMSG_LENGTH(sizeof(struct tcamsg));
 	req.n.nlmsg_flags = NLM_F_REQUEST|flags;
 	req.n.nlmsg_type = cmd;
-- 
2.8.2
