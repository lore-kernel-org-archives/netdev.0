From: Andrew Morton <akpm@osdl.org>
Subject: Re: [Bugme-new] [Bug 7535] New: ARP notifications to NETLINK_ROUTE
Date: Thu, 16 Nov 2006 01:20:36 -0800
Message-ID: <20061116012036.dad4590a.akpm@osdl.org>
References: <200611160911.kAG9BKmP012382@fire-2.osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "bugme-daemon@kernel-bugs.osdl.org"
	<bugme-daemon@bugzilla.kernel.org>, lyricsfan@lycos.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:34202 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S1031147AbWKPJUr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Nov 2006 04:20:47 -0500
To: netdev@vger.kernel.org
In-Reply-To: <200611160911.kAG9BKmP012382@fire-2.osdl.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 16 Nov 2006 01:11:20 -0800
bugme-daemon@bugzilla.kernel.org wrote:

> http://bugzilla.kernel.org/show_bug.cgi?id=7535
> 
>            Summary: ARP notifications to NETLINK_ROUTE
>     Kernel Version: 2.6.16, 2.6.17
>             Status: NEW
>           Severity: normal
>              Owner: shemminger@osdl.org
>          Submitter: lyricsfan@lycos.com
> 
> 
> Most recent kernel where this bug did *NOT* occur:
> 2.6.8 (maybe also some later version, but < 2.6.16)
> 
> Distribution:
> ubuntu 6.06 desktop/server (also with standard kernel 2.6.16), knoppix 5.0.1
> (kernel 2.6.17)
> 
> Hardware Environment:
> irrelevant
> 
> Software Environment:
> irrelevant
> 
> Problem Description:
> While listening to the multicast group RTMGRP_NEIGH on a NETLINK_ROUTE socket,
> on kernel 2.6.8 a RTM_NEWNEIGH message is received whenever an entry is added or
> deleted to the ARP table. On 2.6.16, no such message is received, except for
> IPv6 events.
> Setting "/proc/sys/net/ipv4/neigh/*/app_solicit" to a value > 0 doesn't solve
> the problem.
> 
> Steps to reproduce:
> Open a NETLINK_ROUTE socket and listen to RTMGRP_NEIGH. Try to add a new entry
> to the ARP table, either manually or by pinging a neighbour on the same subnet.
> Try also to manually delete an entry, or simply let it expire. No RTM_NEWNEIGH
> message is triggered when any of these events occurs (it IS in kernel 2.6.8).
> 
