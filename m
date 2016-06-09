From: Ben Dooks <ben.dooks@codethink.co.uk>
Subject: [PATCH] net: ipconfgi: add declaration for ic_addrservaddr
Date: Thu,  9 Jun 2016 12:07:46 +0100
Message-ID: <1465470466-11379-1-git-send-email-ben.dooks@codethink.co.uk>
Cc: Ben Dooks <ben.dooks@codethink.co.uk>,
	"David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>, netdev@vger.kernel.org
To: linux-kernel@lists.codethink.co.uk
Return-path: <netdev-owner@vger.kernel.org>
Received: from 82-70-136-246.dsl.in-addr.zen.co.uk ([82.70.136.246]:58238 "EHLO
	rainbowdash.ducie.codethink.co.uk" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1750909AbcFILIF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 Jun 2016 07:08:05 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The symbol ic_addrservaddr is not static, but has no declaration
to match. Since the similar variables are all exported, add this
one to the header file as well.

This fixes the following warning:

net/ipv4/ipconfig.c:130:8: warning: symbol 'ic_addrservaddr' was not declared. Should it be static?

Signed-off-by: Ben Dooks <ben.dooks@codethink.co.uk>
---
Cc: "David S. Miller" <davem@davemloft.net>
Cc: Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>
Cc: James Morris <jmorris@namei.org>
Cc: Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>
Cc: Patrick McHardy <kaber@trash.net>
Cc: netdev@vger.kernel.org
---
 include/net/ipconfig.h | 1 +
 1 file changed, 1 insertion(+)

diff --git a/include/net/ipconfig.h b/include/net/ipconfig.h
index c74cc1b..e5f4d6e 100644
--- a/include/net/ipconfig.h
+++ b/include/net/ipconfig.h
@@ -13,6 +13,7 @@ extern __be32 ic_myaddr;		/* My IP address */
 extern __be32 ic_gateway;		/* Gateway IP address */
 
 extern __be32 ic_servaddr;		/* Boot server IP address */
+extern __be32 ic_addrservaddr;		/* IP Address of the IP addresses'server */
 
 extern __be32 root_server_addr;	/* Address of NFS server */
 extern u8 root_server_path[];	/* Path to mount as root */
-- 
2.8.1
