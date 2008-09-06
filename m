From: Simon Horman <horms@verge.net.au>
Subject: [PATCH] IPVS: fix bogus indentation
Date: Sat, 6 Sep 2008 14:26:48 +1000
Message-ID: <20080906042644.GD21521@verge.net.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Julius Volz <juliusv@google.com>
To: netdev@vger.kernel.org, lvs-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from kirsty.vergenet.net ([202.4.237.240]:33877 "EHLO
	kirsty.vergenet.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751013AbYIFE0t (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 6 Sep 2008 00:26:49 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Sorry, this was my error.
Thanks to Julius Volz for pointing it out.

Cc: Julius Volz <juliusv@google.com>
Signed-off-by: Simon Horman <horms@verge.net.au>

diff --git a/net/ipv4/ipvs/ip_vs_core.c b/net/ipv4/ipvs/ip_vs_core.c
index 05797a5..1f4f3b9 100644
--- a/net/ipv4/ipvs/ip_vs_core.c
+++ b/net/ipv4/ipvs/ip_vs_core.c
@@ -1033,7 +1033,7 @@ ip_vs_out(unsigned int hooknum, struct sk_buff *skb,
 							  ICMP_DEST_UNREACH,
 							  ICMP_PORT_UNREACH, 0);
 					return NF_DROP;
-			}
+				}
 			}
 		}
 		IP_VS_DBG_PKT(12, pp, skb, 0,

