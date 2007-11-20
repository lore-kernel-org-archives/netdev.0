From: Joe Perches <joe@perches.com>
Subject: [PATCH 53/59] net/ipv6: Add missing "space"
Date: Mon, 19 Nov 2007 17:53:40 -0800
Message-ID: <1195523627-15389-11-git-send-email-joe@perches.com>
References: 1234567
 <1195523627-15389-1-git-send-email-joe@perches.com>
 <1195523627-15389-2-git-send-email-joe@perches.com>
 <1195523627-15389-3-git-send-email-joe@perches.com>
 <1195523627-15389-4-git-send-email-joe@perches.com>
 <1195523627-15389-5-git-send-email-joe@perches.com>
 <1195523627-15389-6-git-send-email-joe@perches.com>
 <1195523627-15389-7-git-send-email-joe@perches.com>
 <1195523627-15389-8-git-send-email-joe@perches.com>
 <1195523627-15389-9-git-send-email-joe@perches.com>
 <1195523627-15389-10-git-send-email-joe@perches.com>
Cc: "Pekka Savola (ipv6)" <pekkas@netcore.fi>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	"David S. Miller" <davem@davemloft.net>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	James Morris <jmorris@namei.org>,
	Networking Team <netdev@vger.kernel.org>,
	Patrick McHardy <kaber@trash.net>
To: linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from DSL022.labridge.com ([206.117.136.22]:2211 "EHLO perches.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758756AbXKTBx5 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 19 Nov 2007 20:53:57 -0500
In-Reply-To: <1195523627-15389-10-git-send-email-joe@perches.com>
Message-Id: <e6a341b03ca9134b944d3021738a795c4e9085c7.1195454436.git.joe@perches.com>
In-Reply-To: <ee1678e1bc8b80b7ae420059fffc7241486ea91a.1195454434.git.joe@perches.com>
References: <ee1678e1bc8b80b7ae420059fffc7241486ea91a.1195454434.git.joe@perches.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Signed-off-by: Joe Perches <joe@perches.com>
---
 net/ipv6/addrconf.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
index 1bd8d81..567664e 100644
--- a/net/ipv6/addrconf.c
+++ b/net/ipv6/addrconf.c
@@ -967,7 +967,7 @@ int ipv6_dev_get_saddr(struct net_device *daddr_dev,
 			if (unlikely(score.addr_type == IPV6_ADDR_ANY ||
 				     score.addr_type & IPV6_ADDR_MULTICAST)) {
 				LIMIT_NETDEBUG(KERN_DEBUG
-					       "ADDRCONF: unspecified / multicast address"
+					       "ADDRCONF: unspecified / multicast address "
 					       "assigned as unicast address on %s",
 					       dev->name);
 				continue;
-- 
1.5.3.5.652.gf192c

