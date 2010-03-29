From: "Edgar E. Iglesias" <edgar.iglesias@gmail.com>
Subject: Re: UDP path MTU discovery
Date: Mon, 29 Mar 2010 22:50:35 +0200
Message-ID: <20100329205035.GA32656@laped.iglesias.mooo.com>
References: <1269561751.2891.8.camel@ilion>
 <877how25kx.fsf@basil.nowhere.org>
 <4BB0DCF6.9020401@hp.com>
 <20100329201431.GH20695@one.firstfloor.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Rick Jones <rick.jones2@hp.com>, Glen Turner <gdt@gdt.id.au>,
	netdev@vger.kernel.org
To: Andi Kleen <andi@firstfloor.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ey-out-2122.google.com ([74.125.78.26]:20106 "EHLO
	ey-out-2122.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752034Ab0C2Uul (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 29 Mar 2010 16:50:41 -0400
Received: by ey-out-2122.google.com with SMTP id d26so1167298eyd.19
        for <netdev@vger.kernel.org>; Mon, 29 Mar 2010 13:50:40 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20100329201431.GH20695@one.firstfloor.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Mar 29, 2010 at 10:14:31PM +0200, Andi Kleen wrote:
> On Mon, Mar 29, 2010 at 10:01:42AM -0700, Rick Jones wrote:
> > >In theory one could probably add some hack in the the kernel UDP code
> > >to hold one packet and retransmit it immediately with fragments when
> > >the ICMP comes in. However that would be quite far in behaviour from
> > >traditional UDP and be considered very ugly. It could also mess up
> > >congestion avoidance schemes done by the application. 
> > >
> > >Still might be preferable over rewriting zillions of applications?
> > 
> > But which of the last N datagrams sent by the application should be 
> > retained for retransmission?  It could be scores if not hundreds of 
> > datagrams depending on the behaviour of the application and the latency to 
> > the narrow part of the network.
> 
> Yes, if there's a large window you lose. I guess it would make protocols
> like DHCP work at least ("transactional UDP" as the original poster called it)
> 
> I don't know if it would fix enough applications to be worth 
> implementing. The only way to find out would be to try I guess.
> I don't have any better ideas.
> 
> > That the IPv6 specification was heavily "influenced" by "the router guys" 
> > seems increasingly clear...
> 
> Yes it sounds like the IETF didn't completely think that through.


Are things really that bad?

These "transactional" IPv6 apps all have the option to stick to 1280
sized datagrams to avoid the problem. If throughput is an issue these
apps will surely benefit from proper PMTUD anyway or?

Cheers
