From: Ying Xue <ying.xue@windriver.com>
Subject: [PATCH net-next] ipv4: Make fib_encap_match static
Date: Wed, 19 Aug 2015 16:04:51 +0800
Message-ID: <1439971491-16210-1-git-send-email-ying.xue@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <davem@davemloft.net>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail1.windriver.com ([147.11.146.13]:37387 "EHLO
	mail1.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753191AbbHSIHD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Aug 2015 04:07:03 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Make fib_encap_match() static as it isn't used outside the file.

Signed-off-by: Ying Xue <ying.xue@windriver.com>
---
 net/ipv4/fib_semantics.c |    6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/net/ipv4/fib_semantics.c b/net/ipv4/fib_semantics.c
index d525307..8fdf6c2 100644
--- a/net/ipv4/fib_semantics.c
+++ b/net/ipv4/fib_semantics.c
@@ -533,9 +533,9 @@ errout:
 
 #endif
 
-int fib_encap_match(struct net *net, u16 encap_type,
-		    struct nlattr *encap,
-		    int oif, const struct fib_nh *nh)
+static int fib_encap_match(struct net *net, u16 encap_type,
+			   struct nlattr *encap,
+			   int oif, const struct fib_nh *nh)
 {
 	struct lwtunnel_state *lwtstate;
 	struct net_device *dev = NULL;
-- 
1.7.9.5
