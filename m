From: Chen Gang <gang.chen@asianux.com>
Subject: [PATCH] Net-next: ipv4: type issue, remove erroneous semicolon
Date: Mon, 22 Apr 2013 18:17:21 +0800
Message-ID: <51750E31.2010906@asianux.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev <netdev@vger.kernel.org>
To: pshelar@nicira.com, kuznet@ms2.inr.ac.ru, jmorris@namei.org,
	yoshfuji@linux-ipv6.org, kaber@trash.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from intranet.asianux.com ([58.214.24.6]:37232 "EHLO
	intranet.asianux.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751119Ab3DVKSH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Apr 2013 06:18:07 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


  need remove erroneous semicolon.

  the related commit number: c54419321455631079c7d6e60bc732dd0c5914c5

  Find it by EXTRA_CFLAGS=-W


Signed-off-by: Chen Gang <gang.chen@asianux.com>
---
 net/ipv4/ip_gre.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/net/ipv4/ip_gre.c b/net/ipv4/ip_gre.c
index 987a4e5..c625e4d 100644
--- a/net/ipv4/ip_gre.c
+++ b/net/ipv4/ip_gre.c
@@ -444,7 +444,7 @@ static netdev_tx_t ipgre_xmit(struct sk_buff *skb,
 	if (dev->header_ops) {
 		/* Need space for new headers */
 		if (skb_cow_head(skb, dev->needed_headroom -
-				      (tunnel->hlen + sizeof(struct iphdr))));
+				      (tunnel->hlen + sizeof(struct iphdr))))
 			goto free_skb;
 
 		tnl_params = (const struct iphdr *)skb->data;
-- 
1.7.7.6
