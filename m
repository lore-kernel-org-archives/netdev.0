From: David Miller <davem@davemloft.net>
Subject: Re: NIU driver: Sun x8 Express Quad Gigabit Ethernet Adapter
Date: Thu, 13 Nov 2008 14:15:13 -0800 (PST)
Message-ID: <20081113.141513.116537651.davem@davemloft.net>
References: <20081112.035240.226243372.davem@davemloft.net>
	<20081112.041143.11487260.davem@davemloft.net>
	<1226572171.6834.87.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: jdb@comx.dk
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:50155
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1756639AbYKMWPN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Nov 2008 17:15:13 -0500
In-Reply-To: <1226572171.6834.87.camel@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jesper Dangaard Brouer <jdb@comx.dk>
Date: Thu, 13 Nov 2008 11:29:31 +0100

> Although I'm not happy about the new perf numbers, as I now on a SMP
> system only can route approx 290 kpps, remember I could route 319 kpps
> using a single CPU nosmp kernel.

That unfortunately (can be) the cost of SMP :-/

With multi-flow tests, Robert Olsson is getting 4.2 mpps rates with
NIU and pktgen.  That's what this card is designed for, good
multi-flow workload performance, rather than striving for maximum
single-flow performance.

> (even more anyoing is that oprofile is broken)

Yes, people on lkml are trying to figure out what is causing
that regression on x86.
