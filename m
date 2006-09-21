From: Rick Jones <rick.jones2@hp.com>
Subject: Question about David's blog entry for NetCONF 2006, Day 1
Date: Thu, 21 Sep 2006 15:15:14 -0700
Message-ID: <45130EF2.2090509@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Return-path: <netdev-owner@vger.kernel.org>
Received: from palrel13.hp.com ([156.153.255.238]:49813 "EHLO palrel13.hp.com")
	by vger.kernel.org with ESMTP id S1751683AbWIUWPP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Sep 2006 18:15:15 -0400
Received: from tardy.cup.hp.com (tardy.cup.hp.com [15.244.56.217])
	by palrel13.hp.com (Postfix) with ESMTP id 08CB537636
	for <netdev@vger.kernel.org>; Thu, 21 Sep 2006 15:15:23 -0700 (PDT)
Received: from [127.0.0.1] (localhost [127.0.0.1])
	by tardy.cup.hp.com (8.9.3 (PHNE_28810)/8.9.3 SMKit7.02) with ESMTP id PAA24763
	for <netdev@vger.kernel.org>; Thu, 21 Sep 2006 15:15:14 -0700 (PDT)
To: Linux Network Development list <netdev@vger.kernel.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

I was reading David's blog entries on the netdev meeting in Japan, and 
have a question about this bit:

> Currently, things like Xen have to put the card into promiscuous
> mode, accepting all packets, which is quite inefficient.

Is the inefficient bit meant for accepting all packets, or more broadly 
that the promiscuous path is quite inefficient compared to the 
non-promiscuous path?

I ask because I would have thought that if the system were connected to 
a switch (*), the number of packets received through a NIC in 
promiscuous mode would be nearly the same as when it was not in 
promiscuous mode - the delta being (perhaps) multicast frames.

rick jones

(*) "Today," it seems 99 times out of 10 systems are connected to 
switches not hubs.
