From: Tom Gundersen <teg@jklm.no>
Subject: [PATCH v7 13/33] net: mrt - set name assign type
Date: Thu, 10 Jul 2014 10:17:18 +0200
Message-ID: <1404980258-30853-14-git-send-email-teg@jklm.no>
References: <1404980258-30853-1-git-send-email-teg@jklm.no>
Cc: linux-kernel@vger.kernel.org, David Miller <davem@davemloft.net>,
	David Herrmann <dh.herrmann@gmail.com>,
	Kay Sievers <kay@vrfy.org>, Tom Gundersen <teg@jklm.no>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f50.google.com ([209.85.215.50]:60961 "EHLO
	mail-la0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752154AbaGJIS2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 Jul 2014 04:18:28 -0400
Received: by mail-la0-f50.google.com with SMTP id pv20so5908616lab.9
        for <netdev@vger.kernel.org>; Thu, 10 Jul 2014 01:18:27 -0700 (PDT)
In-Reply-To: <1404980258-30853-1-git-send-email-teg@jklm.no>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We have one device per routing table, so the naming is predictable.

Signed-off-by: Tom Gundersen <teg@jklm.no>
Cc: Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>
Cc: James Morris <jmorris@namei.org>
Cc: Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>
Cc: Patrick McHardy <kaber@trash.net>
---
 net/ipv4/ipmr.c  | 2 +-
 net/ipv6/ip6mr.c | 2 +-
 2 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/ipv4/ipmr.c b/net/ipv4/ipmr.c
index c803458..a0658a2 100644
--- a/net/ipv4/ipmr.c
+++ b/net/ipv4/ipmr.c
@@ -500,7 +500,7 @@ static struct net_device *ipmr_reg_vif(struct net *net, struct mr_table *mrt)
 	else
 		sprintf(name, "pimreg%u", mrt->id);
 
-	dev = alloc_netdev(0, name, NET_NAME_UNKNOWN, reg_vif_setup);
+	dev = alloc_netdev(0, name, NET_NAME_PREDICTABLE, reg_vif_setup);
 
 	if (dev == NULL)
 		return NULL;
diff --git a/net/ipv6/ip6mr.c b/net/ipv6/ip6mr.c
index f9a3fd3..cb25ff0 100644
--- a/net/ipv6/ip6mr.c
+++ b/net/ipv6/ip6mr.c
@@ -744,7 +744,7 @@ static struct net_device *ip6mr_reg_vif(struct net *net, struct mr6_table *mrt)
 	else
 		sprintf(name, "pim6reg%u", mrt->id);
 
-	dev = alloc_netdev(0, name, NET_NAME_UNKNOWN, reg_vif_setup);
+	dev = alloc_netdev(0, name, NET_NAME_PREDICTABLE, reg_vif_setup);
 	if (dev == NULL)
 		return NULL;
 
-- 
1.9.3
