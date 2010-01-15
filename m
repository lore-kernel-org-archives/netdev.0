From: Krishna Kumar <krkumar2@in.ibm.com>
Subject: [PATCH] Remove unused function - skb_frag_add_head
Date: Fri, 15 Jan 2010 11:02:05 +0530
Message-ID: <20100115053205.31534.85551.sendpatchset@krkumar2.in.ibm.com>
Cc: netdev@vger.kernel.org, Krishna Kumar <krkumar2@in.ibm.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from e23smtp02.au.ibm.com ([202.81.31.144]:56401 "EHLO
	e23smtp02.au.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750818Ab0AOFcK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 15 Jan 2010 00:32:10 -0500
Received: from d23relay05.au.ibm.com (d23relay05.au.ibm.com [202.81.31.247])
	by e23smtp02.au.ibm.com (8.14.3/8.13.1) with ESMTP id o0F5TE1s007976
	for <netdev@vger.kernel.org>; Fri, 15 Jan 2010 16:29:14 +1100
Received: from d23av01.au.ibm.com (d23av01.au.ibm.com [9.190.234.96])
	by d23relay05.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id o0F5RV6d1499234
	for <netdev@vger.kernel.org>; Fri, 15 Jan 2010 16:27:31 +1100
Received: from d23av01.au.ibm.com (loopback [127.0.0.1])
	by d23av01.au.ibm.com (8.14.3/8.13.1/NCO v10.0 AVout) with ESMTP id o0F5W8IU027562
	for <netdev@vger.kernel.org>; Fri, 15 Jan 2010 16:32:08 +1100
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Krishna Kumar <krkumar2@in.ibm.com>

Remove unused function - skb_frag_add_head

Signed-off-by: Krishna Kumar <krkumar2@in.ibm.com>
---
 include/linux/skbuff.h |    6 ------
 1 file changed, 6 deletions(-)

diff -ruNp org/include/linux/skbuff.h new/include/linux/skbuff.h
--- org/include/linux/skbuff.h	2009-12-29 18:29:33.000000000 +0530
+++ new/include/linux/skbuff.h	2009-12-29 18:30:06.000000000 +0530
@@ -1728,12 +1728,6 @@ static inline void skb_frag_list_init(st
 	skb_shinfo(skb)->frag_list = NULL;
 }
 
-static inline void skb_frag_add_head(struct sk_buff *skb, struct sk_buff *frag)
-{
-	frag->next = skb_shinfo(skb)->frag_list;
-	skb_shinfo(skb)->frag_list = frag;
-}
-
 #define skb_walk_frags(skb, iter)	\
 	for (iter = skb_shinfo(skb)->frag_list; iter; iter = iter->next)
 
