From: Andi Kleen <andi@firstfloor.org>
Subject: Re: UDP path MTU discovery
Date: Tue, 30 Mar 2010 08:16:27 +0200
Message-ID: <20100330061627.GM20695@one.firstfloor.org>
References: <1269561751.2891.8.camel@ilion> <877how25kx.fsf@basil.nowhere.org> <4BB0DCF6.9020401@hp.com> <20100329201431.GH20695@one.firstfloor.org> <20100329205035.GA32656@laped.iglesias.mooo.com> <4BB11510.9000302@hp.com> <1269898152.1958.86.camel@edumazet-laptop> <E1829B60731D1740BB7A0626B4FAF0A649E05EAAB5@XCH-NW-01V.nw.nos.boeing.com> <20100330052044.GJ20695@one.firstfloor.org> <1269929168.1958.94.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andi Kleen <andi@firstfloor.org>,
	"Templin, Fred L" <Fred.L.Templin@boeing.com>,
	Rick Jones <rick.jones2@hp.com>,
	"Edgar E. Iglesias" <edgar.iglesias@gmail.com>,
	Glen Turner <gdt@gdt.id.au>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from one.firstfloor.org ([213.235.205.2]:51630 "EHLO
	one.firstfloor.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755559Ab0C3GQ3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 30 Mar 2010 02:16:29 -0400
Content-Disposition: inline
In-Reply-To: <1269929168.1958.94.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> > Right now there is no right socket option to set the path mtu. We
> > have a IP_MTU option, but it only works for getting the MTU.
> > That's because the PMTU is in the routing cache entry and shared
> > by multiple sockets. Presumably one could add a special case
> > with an MTU in the socket overriding the one in the destination entry.
> 
> We have IP_MTU_DISCOVER option with four existing values

I think you would just need a sk->pmtu and a option to set/unset it
Or perhaps just a flag that clamps to 1280? 

Then the existing mtu discover options would be sufficient.

-Andi
-- 
ak@linux.intel.com -- Speaking for myself only.
