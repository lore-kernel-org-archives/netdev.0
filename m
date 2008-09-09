From: David Miller <davem@davemloft.net>
Subject: [PATCH]: ipsec: Make xfrm_larval_drop default to 1.
Date: Tue, 09 Sep 2008 16:09:24 -0700 (PDT)
Message-ID: <20080909.160924.203522684.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:33024
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753375AbYIIXJa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Sep 2008 19:09:30 -0400
Received: from localhost (localhost [127.0.0.1])
	by sunset.davemloft.net (Postfix) with ESMTP id 6138DC8C17E
	for <netdev@vger.kernel.org>; Tue,  9 Sep 2008 16:09:24 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


I've threatened to do this in the past, now I finally pulled
the trigger.  :-) Pushed to net-next-2.6

ipsec: Make xfrm_larval_drop default to 1.

The previous default behavior is definitely the least user
friendly.  Hanging there forever just because the keying
daemon is wedged or the refreshing of the policy can't move
forward is anti-social to say the least.

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 net/xfrm/xfrm_policy.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/net/xfrm/xfrm_policy.c b/net/xfrm/xfrm_policy.c
index 46914b7..638bb5f 100644
--- a/net/xfrm/xfrm_policy.c
+++ b/net/xfrm/xfrm_policy.c
@@ -34,7 +34,7 @@
 
 #include "xfrm_hash.h"
 
-int sysctl_xfrm_larval_drop __read_mostly;
+int sysctl_xfrm_larval_drop __read_mostly = 1;
 
 #ifdef CONFIG_XFRM_STATISTICS
 DEFINE_SNMP_STAT(struct linux_xfrm_mib, xfrm_statistics) __read_mostly;
-- 
1.5.6.5.GIT

