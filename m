From: Chen Gang <gang.chen@asianux.com>
Subject: [PATCH net-next v3] net: ipv4: typo issue, remove erroneous semicolon
Date: Tue, 23 Apr 2013 14:45:42 +0800
Message-ID: <51762E16.703@asianux.com>
References: <517549F4.7030806@cogentembedded.com> <5175DFF9.4040000@asianux.com> <5175F5C3.8060503@asianux.com> <20130423.011604.1061769362231812796.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: sergei.shtylyov@cogentembedded.com, pshelar@nicira.com,
	kuznet@ms2.inr.ac.ru, jmorris@namei.org, yoshfuji@linux-ipv6.org,
	kaber@trash.net, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from intranet.asianux.com ([58.214.24.6]:10368 "EHLO
	intranet.asianux.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755089Ab3DWGq3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 Apr 2013 02:46:29 -0400
In-Reply-To: <20130423.011604.1061769362231812796.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Need remove erroneous semicolon, which is found by EXTRA_CFLAGS=-W,
the related commit number: c54419321455631079c7d6e60bc732dd0c5914c5
("GRE: Refactor GRE tunneling code")


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
