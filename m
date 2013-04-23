From: Chen Gang <gang.chen@asianux.com>
Subject: [PATCH v2] Net-next: ipv4: typo issue, remove erroneous semicolon
Date: Tue, 23 Apr 2013 10:45:23 +0800
Message-ID: <5175F5C3.8060503@asianux.com>
References: <51750E31.2010906@asianux.com> <517549F4.7030806@cogentembedded.com> <5175DFF9.4040000@asianux.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: pshelar@nicira.com, kuznet@ms2.inr.ac.ru, jmorris@namei.org,
	yoshfuji@linux-ipv6.org, kaber@trash.net,
	David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>
To: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from intranet.asianux.com ([58.214.24.6]:47660 "EHLO
	intranet.asianux.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754040Ab3DWCqK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Apr 2013 22:46:10 -0400
In-Reply-To: <5175DFF9.4040000@asianux.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


need remove erroneous semicolon, which is found by EXTRA_CFLAGS=-W.
the related commit number: c54419321455631079c7d6e60bc732dd0c5914c5
(by Pravin B Shelar <pshelar@nicira.com>  Mon Mar 25 14:49:35 2013)

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
