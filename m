From: kaber@trash.net
Subject: [PATCH 19/26] IPVS: Remove unused variables
Date: Thu,  3 Feb 2011 00:11:57 +0100
Message-ID: <1296688324-7830-20-git-send-email-kaber@trash.net>
References: <1296688324-7830-1-git-send-email-kaber@trash.net>
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1296688324-7830-1-git-send-email-kaber@trash.net>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Simon Horman <horms@verge.net.au>

These variables are unused as a result of the recent netns work.

Signed-off-by: Simon Horman <horms@verge.net.au>
Acked-by: Randy Dunlap <randy.dunlap@oracle.com>
Signed-off-by: Hans Schillstrom <hans@schillstrom.com>
Tested-by: Hans Schillstrom <hans@schillstrom.com>
Signed-off-by: Patrick McHardy <kaber@trash.net>
---
 include/net/ip_vs.h |    2 --
 1 files changed, 0 insertions(+), 2 deletions(-)

diff --git a/include/net/ip_vs.h b/include/net/ip_vs.h
index b23bea6..5d75fea 100644
--- a/include/net/ip_vs.h
+++ b/include/net/ip_vs.h
@@ -1109,8 +1109,6 @@ extern int ip_vs_icmp_xmit_v6
  *	we are loaded. Just set ip_vs_drop_rate to 'n' and
  *	we start to drop 1/rate of the packets
  */
-extern int ip_vs_drop_rate;
-extern int ip_vs_drop_counter;
 
 static inline int ip_vs_todrop(struct netns_ipvs *ipvs)
 {
-- 
1.7.2.3

