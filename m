From: Daniel Lezcano <dlezcano@fr.ibm.com>
Subject: [patch net-2.6.26][NETNS][IPV6] remove commented lines
Date: Wed, 05 Mar 2008 21:34:17 +0100
Message-ID: <47CF03C9.1050704@fr.ibm.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------040502070607060802050308"
Cc: Linux Netdev List <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate6.uk.ibm.com ([195.212.29.139]:61074 "EHLO
	mtagate6.uk.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752790AbYCEUe1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 5 Mar 2008 15:34:27 -0500
Received: from d06nrmr1407.portsmouth.uk.ibm.com (d06nrmr1407.portsmouth.uk.ibm.com [9.149.38.185])
	by mtagate6.uk.ibm.com (8.13.8/8.13.8) with ESMTP id m25KYPrC070010
	for <netdev@vger.kernel.org>; Wed, 5 Mar 2008 20:34:25 GMT
Received: from d06av04.portsmouth.uk.ibm.com (d06av04.portsmouth.uk.ibm.com [9.149.37.216])
	by d06nrmr1407.portsmouth.uk.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id m25KYPaU1282294
	for <netdev@vger.kernel.org>; Wed, 5 Mar 2008 20:34:25 GMT
Received: from d06av04.portsmouth.uk.ibm.com (loopback [127.0.0.1])
	by d06av04.portsmouth.uk.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m25KYP3E014275
	for <netdev@vger.kernel.org>; Wed, 5 Mar 2008 20:34:25 GMT
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------040502070607060802050308
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit



--------------040502070607060802050308
Content-Type: text/x-patch;
 name="netns-ipv6-addrconf-fix-comment.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="netns-ipv6-addrconf-fix-comment.patch"

Subject: remove commented lines
From: Daniel Lezcano <dlezcano@fr.ibm.com>

Remove commented lines from netns patchset.

Signed-off-by: Daniel Lezcano <dlezcano@fr.ibm.com>
---
 net/ipv6/addrconf.c |    9 ---------
 1 file changed, 9 deletions(-)

Index: net-2.6.26/net/ipv6/addrconf.c
===================================================================
--- net-2.6.26.orig/net/ipv6/addrconf.c
+++ net-2.6.26/net/ipv6/addrconf.c
@@ -4259,15 +4259,6 @@ static void addrconf_net_exit(struct net
 {
 	struct net_device *dev;
 
-	/*
-	 * Remove loopback references from default routing entries
-	 */
-/* 	in6_dev_put(net->ipv6.ip6_null_entry->rt6i_idev); */
-/* #ifdef CONFIG_IPV6_MULTIPLE_TABLES */
-/* 	in6_dev_put(net->ipv6.ip6_prohibit_entry->rt6i_idev); */
-/* 	in6_dev_put(net->ipv6.ip6_blk_hole_entry->rt6i_idev); */
-/* #endif */
-
 	rtnl_lock();
 	/* clean dev list */
 	for_each_netdev(net, dev) {

--------------040502070607060802050308--
