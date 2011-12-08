From: John Fastabend <john.r.fastabend@intel.com>
Subject: [net-next PATCH] net: netprio_cgroup: make net_prio_subsys static
Date: Wed, 07 Dec 2011 21:17:17 -0800
Message-ID: <20111208051717.20236.41881.stgit@jf-dev1-dcblab>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: davem@davemloft.net, nhorman@tuxdriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:24262 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750781Ab1LHF13 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 8 Dec 2011 00:27:29 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

net_prio_subsys can be made static this removes the sparse
warning it was throwing.

Signed-off-by: John Fastabend <john.r.fastabend@intel.com>
---

 net/core/netprio_cgroup.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/net/core/netprio_cgroup.c b/net/core/netprio_cgroup.c
index 3a9fd48..ea16c8f 100644
--- a/net/core/netprio_cgroup.c
+++ b/net/core/netprio_cgroup.c
@@ -28,7 +28,7 @@ static struct cgroup_subsys_state *cgrp_create(struct cgroup_subsys *ss,
 static void cgrp_destroy(struct cgroup_subsys *ss, struct cgroup *cgrp);
 static int cgrp_populate(struct cgroup_subsys *ss, struct cgroup *cgrp);
 
-struct cgroup_subsys net_prio_subsys = {
+static struct cgroup_subsys net_prio_subsys = {
 	.name		= "net_prio",
 	.create		= cgrp_create,
 	.destroy	= cgrp_destroy,
