From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [PATCH v6] net: batch skb dequeueing from softnet input_pkt_queue
Date: Mon, 3 May 2010 12:34:26 +0200
Message-ID: <20100503103426.GA25809@one.firstfloor.org>
References: <1272783366.2173.13.camel@edumazet-laptop> <20100502092020.GA9655@gargoyle.fritz.box> <1272797690.2173.26.camel@edumazet-laptop> <20100502071324.1a95fdad@infradead.org> <1272810448.2173.31.camel@edumazet-laptop> <20100502105418.7abf83a7@infradead.org> <1272828143.2173.150.camel@edumazet-laptop> <20100502205044.450beda2@infradead.org> <1272863834.2173.173.camel@edumazet-laptop> <20100503032227.268613ac@infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	Andi Kleen <andi@firstfloor.org>,
	David Miller <davem@davemloft.net>, hadi@cyberus.ca,
	xiaosuo@gmail.com, therbert@google.com, shemminger@vyatta.com,
	netdev@vger.kernel.org, lenb@kernel.org
To: Arjan van de Ven <arjan@infradead.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from one.firstfloor.org ([213.235.205.2]:58998 "EHLO
	one.firstfloor.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754516Ab0ECKeb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 3 May 2010 06:34:31 -0400
Content-Disposition: inline
In-Reply-To: <20100503032227.268613ac@infradead.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> > Maybe its low cost, (apparently, it is, since I can reach ~900.000
> > ipis on my 16 cores machine) but multiply this by 16 or 32 or 64
> > cpus, and clockevents_notify() cost appears to be a killer, all cpus
> > compete on a single lock.
> > 
> > Maybe this notifier could use RCU ?
> 
> could this be an artifact of the local apic stopping in deeper C states?
> (which is finally fixed in the Westmere generation)

Yes it is I think.

But I suspect Eric wants a solution for Nehalem.

-Andi
-- 
ak@linux.intel.com -- Speaking for myself only.
