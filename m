From: Thomas Graf <tgraf@suug.ch>
Subject: [PATCH net-next] ipv6: ndisc: remove redundant check for !dev->addr_len
Date: Fri,  8 Mar 2013 12:03:46 +0100
Message-ID: <85f9fbce9b5a6ccc4e75b05dab268076e0574abf.1362740080.git.tgraf@suug.ch>
Cc: netdev@vger.kernel.org, Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 173-166-109-252-newengland.hfc.comcastbusiness.net ([173.166.109.252]:52092
	"EHLO bombadil.infradead.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932087Ab3CHLDx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 Mar 2013 06:03:53 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

send_sllao is already initialized with the value of dev->addr_len

Cc: Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>
Signed-off-by: Thomas Graf <tgraf@suug.ch>
---
 net/ipv6/ndisc.c | 2 --
 1 file changed, 2 deletions(-)

diff --git a/net/ipv6/ndisc.c b/net/ipv6/ndisc.c
index 76ef435..2712ab2 100644
--- a/net/ipv6/ndisc.c
+++ b/net/ipv6/ndisc.c
@@ -610,8 +610,6 @@ void ndisc_send_rs(struct net_device *dev, const struct in6_addr *saddr,
 		}
 	}
 #endif
-	if (!dev->addr_len)
-		send_sllao = 0;
 	if (send_sllao)
 		optlen += ndisc_opt_addr_space(dev);
 
-- 
1.7.11.7
