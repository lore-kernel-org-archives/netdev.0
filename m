From: Vegard Nossum <vegard.nossum@oracle.com>
Subject: [PATCH] net: mark DECnet as broken
Date: Thu,  7 Apr 2016 09:22:43 +0200
Message-ID: <1460013763-22985-1-git-send-email-vegard.nossum@oracle.com>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Vegard Nossum <vegard.nossum@oracle.com>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Sasha Levin <sasha.levin@oracle.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from aserp1040.oracle.com ([141.146.126.69]:36299 "EHLO
	aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751260AbcDGHWz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Apr 2016 03:22:55 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

There are NULL pointer dereference bugs in DECnet which can be triggered
by unprivileged users and have been reported multiple times to LKML,
however nobody seems confident enough in the proposed fixes to merge them
and the consensus seems to be that nobody cares enough about DECnet to
see it fixed anyway.

To shield unsuspecting users from the possible DOS, we should mark this
BROKEN until somebody who actually uses this code can fix it.

Signed-off-by: Vegard Nossum <vegard.nossum@oracle.com>
Link: https://lkml.org/lkml/2015/12/17/666
Cc: Eric Dumazet <eric.dumazet@gmail.com>
Cc: Sasha Levin <sasha.levin@oracle.com>
Cc: David Miller <davem@davemloft.net>
---
 net/decnet/Kconfig | 1 +
 1 file changed, 1 insertion(+)

diff --git a/net/decnet/Kconfig b/net/decnet/Kconfig
index f3393e1..b040172 100644
--- a/net/decnet/Kconfig
+++ b/net/decnet/Kconfig
@@ -3,6 +3,7 @@
 #
 config DECNET
 	tristate "DECnet Support"
+	depends on BROKEN
 	---help---
 	  The DECnet networking protocol was used in many products made by
 	  Digital (now Compaq).  It provides reliable stream and sequenced
-- 
1.9.1
