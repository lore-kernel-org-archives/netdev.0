From: Patrick McHardy <kaber@trash.net>
Subject: [NET_SCHED 01/15]: sch_atm: fix format string warning
Date: Wed, 23 Jan 2008 17:36:37 +0100 (MET)
Message-ID: <20080123163556.6459.76384.sendpatchset@localhost.localdomain>
References: <20080123163555.6459.69501.sendpatchset@localhost.localdomain>
Cc: netdev@vger.kernel.org, Patrick McHardy <kaber@trash.net>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:49711 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754571AbYAWQgi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Jan 2008 11:36:38 -0500
In-Reply-To: <20080123163555.6459.69501.sendpatchset@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

[NET_SCHED]: sch_atm: fix format string warning

Fix format string warning introduces by the netlink API conversion:

net/sched/sch_atm.c:250: warning: format '%lu' expects type 'long unsigned int', but argument 3 has type 'int'.

Signed-off-by: Patrick McHardy <kaber@trash.net>

---
commit 3bab4166cf0350552419d7871b4df463c5aed2ea
tree c08015e39f6f1da0255f1325cc21dfda0c738bc2
parent a7f92e3b13a5e3db64383c503f2249dc74b41bd6
author Patrick McHardy <kaber@trash.net> Wed, 23 Jan 2008 16:48:28 +0100
committer Patrick McHardy <kaber@trash.net> Wed, 23 Jan 2008 16:48:28 +0100

 net/sched/sch_atm.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/net/sched/sch_atm.c b/net/sched/sch_atm.c
index eb01aae..e587391 100644
--- a/net/sched/sch_atm.c
+++ b/net/sched/sch_atm.c
@@ -246,7 +246,7 @@ static int atm_tc_change(struct Qdisc *sch, u32 classid, u32 parent,
 		if (!excess)
 			return -ENOENT;
 	}
-	pr_debug("atm_tc_change: type %d, payload %lu, hdr_len %d\n",
+	pr_debug("atm_tc_change: type %d, payload %d, hdr_len %d\n",
 		 opt->nla_type, nla_len(opt), hdr_len);
 	sock = sockfd_lookup(fd, &error);
 	if (!sock)
