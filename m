From: Ben Dooks <ben.dooks@codethink.co.uk>
Subject: [PATCH] [V3] net: ipconfig: avoid warning by making ic_addrservaddr static
Date: Fri, 10 Jun 2016 12:11:06 +0100
Message-ID: <1465557066-3968-1-git-send-email-ben.dooks@codethink.co.uk>
Cc: Ben Dooks <ben.dooks@codethink.co.uk>,
	"David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>, netdev@vger.kernel.org
To: linux-kernel@lists.codethink.co.uk
Return-path: <netdev-owner@vger.kernel.org>
Received: from 82-70-136-246.dsl.in-addr.zen.co.uk ([82.70.136.246]:57802 "EHLO
	rainbowdash.ducie.codethink.co.uk" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1752706AbcFJLMO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Jun 2016 07:12:14 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The symbol ic_addrservaddr is not static, but has no declaration
to match so make it static to fix the following warning:

net/ipv4/ipconfig.c:130:8: warning: symbol 'ic_addrservaddr' was not declared. Should it be static?

Signed-off-by: Ben Dooks <ben.dooks@codethink.co.uk>
---
V3: fix the title from V2
V2: make ic_addrservaddr static instead of adding to header
---
Cc: "David S. Miller" <davem@davemloft.net>
Cc: Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>
Cc: James Morris <jmorris@namei.org>
Cc: Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>
Cc: Patrick McHardy <kaber@trash.net>
Cc: netdev@vger.kernel.org
---
 net/ipv4/ipconfig.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/ipv4/ipconfig.c b/net/ipv4/ipconfig.c
index 2ed9dd2..eccf9fd 100644
--- a/net/ipv4/ipconfig.c
+++ b/net/ipv4/ipconfig.c
@@ -127,7 +127,7 @@ __be32 ic_myaddr = NONE;		/* My IP address */
 static __be32 ic_netmask = NONE;	/* Netmask for local subnet */
 __be32 ic_gateway = NONE;	/* Gateway IP address */
 
-__be32 ic_addrservaddr = NONE;	/* IP Address of the IP addresses'server */
+static __be32 ic_addrservaddr = NONE;	/* IP Address of the IP addresses'server */
 
 __be32 ic_servaddr = NONE;	/* Boot server IP address */
 
-- 
2.8.1
