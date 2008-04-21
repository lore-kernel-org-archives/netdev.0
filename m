From: Adrian Bunk <bunk@kernel.org>
Subject: [2.6 patch] make struct ip6_prohibit_entry_template static
Date: Mon, 21 Apr 2008 11:48:41 +0300
Message-ID: <20080421084841.GQ26897@cs181133002.pp.htv.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: netdev@vger.kernel.org
To: Daniel Lezcano <dlezcano@fr.ibm.com>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp4.pp.htv.fi ([213.243.153.38]:35076 "EHLO smtp4.pp.htv.fi"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754653AbYDUItL (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 21 Apr 2008 04:49:11 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch makes the needlessly global struct 
ip6_prohibit_entry_template static.

Signed-off-by: Adrian Bunk <bunk@kernel.org>

---
--- a/net/ipv6/route.c
+++ b/net/ipv6/route.c
@@ -150,7 +150,7 @@ static struct rt6_info ip6_null_entry_template = {
 static int ip6_pkt_prohibit(struct sk_buff *skb);
 static int ip6_pkt_prohibit_out(struct sk_buff *skb);
 
-struct rt6_info ip6_prohibit_entry_template = {
+static struct rt6_info ip6_prohibit_entry_template = {
 	.u = {
 		.dst = {
 			.__refcnt	= ATOMIC_INIT(1),
