From: kbuild test robot <fengguang.wu@intel.com>
Subject: [RFC PATCH net-next] tipc: tipc_link_is_active() can be static
Date: Sat, 24 Oct 2015 23:11:00 +0800
Message-ID: <20151024151100.GA46525@lkp-hsx03>
References: <201510242340.mc7bt8l1%fengguang.wu@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: kbuild-all@01.org, netdev@vger.kernel.org
To: kbuild-internal@linux.intel.com, lkp@eclists.intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:63243 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751803AbbJXPMl (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 24 Oct 2015 11:12:41 -0400
Content-Disposition: inline
In-Reply-To: <201510242340.mc7bt8l1%fengguang.wu@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

TO: "David S. Miller" <davem@davemloft.net>
CC: netdev@vger.kernel.org
CC: Jon Maloy <jon.maloy@ericsson.com>
CC: Ying Xue <ying.xue@windriver.com>
CC: tipc-discussion@lists.sourceforge.net
CC: linux-kernel@vger.kernel.org


Signed-off-by: Fengguang Wu <fengguang.wu@intel.com>
---
 link.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/tipc/link.c b/net/tipc/link.c
index 4449fa0..b637276 100644
--- a/net/tipc/link.c
+++ b/net/tipc/link.c
@@ -173,7 +173,7 @@ bool link_is_bc_rcvlink(struct tipc_link *l)
 	return ((l->bc_rcvlink == l) && !link_is_bc_sndlink(l));
 }
 
-int tipc_link_is_active(struct tipc_link *l)
+static int tipc_link_is_active(struct tipc_link *l)
 {
 	return l->active;
 }
