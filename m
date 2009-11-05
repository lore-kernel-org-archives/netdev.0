From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [RFC] [PATCH] udp: optimize lookup of UDP sockets to by including destination address in the hash key
Date: Thu, 05 Nov 2009 13:12:07 +0100
Message-ID: <877hu5892g.fsf@basil.nowhere.org>
References: <4AF1EC18.9090106@ixiacom.com> <4AF1F273.5020207@gmail.com>
	<200911050104.09538.opurdila@ixiacom.com> <4AF20F02.7000601@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Octavian Purdila <opurdila@ixiacom.com>,
	Lucian Adrian Grijincu <lgrijincu@ixiacom.com>,
	netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from one.firstfloor.org ([213.235.205.2]:46905 "EHLO
	one.firstfloor.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755463AbZKEMMD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Nov 2009 07:12:03 -0500
In-Reply-To: <4AF20F02.7000601@gmail.com> (Eric Dumazet's message of "Thu, 05 Nov 2009 00:32:18 +0100")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Eric Dumazet <eric.dumazet@gmail.com> writes:
>
> I have struct reorderings in progress to reduce number of cache lines read
> per socket from two to one. So this would reduce by 50% time to find
> a particular socket in the chain.

Assuming that each access takes equal time seems like a rather dubious
assumption. Consider caches.

-Andi
-- 
ak@linux.intel.com -- Speaking for myself only.
