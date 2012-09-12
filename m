From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next] ipv6: route templates can be const
Date: Wed, 12 Sep 2012 09:47:51 +0200
Message-ID: <1347436071.13103.695.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ey0-f174.google.com ([209.85.215.174]:46708 "EHLO
	mail-ey0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751147Ab2ILHr7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Sep 2012 03:47:59 -0400
Received: by eaac11 with SMTP id c11so663661eaa.19
        for <netdev@vger.kernel.org>; Wed, 12 Sep 2012 00:47:58 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

We kmemdup() templates, so they can be const.

Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 net/ipv6/route.c |    6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)
diff --git a/net/ipv6/route.c b/net/ipv6/route.c
index 399613b..f568ac6 100644
--- a/net/ipv6/route.c
+++ b/net/ipv6/route.c
@@ -222,7 +222,7 @@ static const u32 ip6_template_metrics[RTAX_MAX] = {
 	[RTAX_HOPLIMIT - 1] = 255,
 };
 
-static struct rt6_info ip6_null_entry_template = {
+static const struct rt6_info ip6_null_entry_template = {
 	.dst = {
 		.__refcnt	= ATOMIC_INIT(1),
 		.__use		= 1,
@@ -242,7 +242,7 @@ static struct rt6_info ip6_null_entry_template = {
 static int ip6_pkt_prohibit(struct sk_buff *skb);
 static int ip6_pkt_prohibit_out(struct sk_buff *skb);
 
-static struct rt6_info ip6_prohibit_entry_template = {
+static const struct rt6_info ip6_prohibit_entry_template = {
 	.dst = {
 		.__refcnt	= ATOMIC_INIT(1),
 		.__use		= 1,
@@ -257,7 +257,7 @@ static struct rt6_info ip6_prohibit_entry_template = {
 	.rt6i_ref	= ATOMIC_INIT(1),
 };
 
-static struct rt6_info ip6_blk_hole_entry_template = {
+static const struct rt6_info ip6_blk_hole_entry_template = {
 	.dst = {
 		.__refcnt	= ATOMIC_INIT(1),
 		.__use		= 1,
