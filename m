From: Simon Horman <horms@verge.net.au>
Subject: [PATCH nf-next 1/2] sections, ipvs: Remove useless __read_mostly for ipvs genl_ops
Date: Fri,  7 Mar 2014 12:46:13 +0900
Message-ID: <1394163974-25877-2-git-send-email-horms@verge.net.au>
References: <1394163974-25877-1-git-send-email-horms@verge.net.au>
Cc: lvs-devel@vger.kernel.org, netdev@vger.kernel.org,
	netfilter-devel@vger.kernel.org,
	Wensong Zhang <wensong@linux-vs.org>,
	Julian Anastasov <ja@ssi.bg>, Andi Kleen <ak@linux.intel.com>,
	Simon Horman <horms@verge.net.au>,
	Patrick McHardy <kaber@trash.net>
To: Pablo Neira Ayuso <pablo@netfilter.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from kirsty.vergenet.net ([202.4.237.240]:55701 "EHLO
	kirsty.vergenet.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751639AbaCGDqW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 6 Mar 2014 22:46:22 -0500
In-Reply-To: <1394163974-25877-1-git-send-email-horms@verge.net.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Andi Kleen <ak@linux.intel.com>

const __read_mostly does not make any sense, because const
data is already read-only. Remove the __read_mostly
for the ipvs genl_ops. This avoids a LTO
section conflict compile problem.

Cc: Wensong Zhang <wensong@linux-vs.org>
Cc: Simon Horman <horms@verge.net.au>
Cc: Patrick McHardy <kaber@trash.net>
Cc: lvs-devel@vger.kernel.org
Signed-off-by: Andi Kleen <ak@linux.intel.com>
Signed-off-by: Simon Horman <horms@verge.net.au>
---
 net/netfilter/ipvs/ip_vs_ctl.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/netfilter/ipvs/ip_vs_ctl.c b/net/netfilter/ipvs/ip_vs_ctl.c
index 35be035..2a68a38 100644
--- a/net/netfilter/ipvs/ip_vs_ctl.c
+++ b/net/netfilter/ipvs/ip_vs_ctl.c
@@ -3580,7 +3580,7 @@ out:
 }
 
 
-static const struct genl_ops ip_vs_genl_ops[] __read_mostly = {
+static const struct genl_ops ip_vs_genl_ops[] = {
 	{
 		.cmd	= IPVS_CMD_NEW_SERVICE,
 		.flags	= GENL_ADMIN_PERM,
-- 
1.8.5.2
