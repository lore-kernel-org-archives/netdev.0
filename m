From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH net-next] gro: Handle inline VLAN tags
Date: Sat, 17 Nov 2012 00:32:04 +0000
Message-ID: <1353112324.2743.81.camel@bwh-desktop.uk.solarflarecom.com>
References: <1353097030.2743.28.camel@bwh-desktop.uk.solarflarecom.com>
	 <1353106865.10798.61.camel@edumazet-glaptop>
	 <1353110430.2743.73.camel@bwh-desktop.uk.solarflarecom.com>
	 <1353111414.10798.64.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>,
	<linux-net-drivers@solarflare.com>,
	Andrew Gallatin <gallatin@myri.com>,
	Herbert Xu <herbert@gondor.apana.org.au>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:36275 "EHLO
	webmail.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753832Ab2KQAcH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 Nov 2012 19:32:07 -0500
In-Reply-To: <1353111414.10798.64.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2012-11-16 at 16:16 -0800, Eric Dumazet wrote:
> On Sat, 2012-11-17 at 00:00 +0000, Ben Hutchings wrote:
> 
> > I'm not sure what you mean by this.  Is your point that the
> > copy-on-write is never needed?  It is still possible for pskb_may_pull()
> > to fail.
> > 
> 
> A packet sniffer should have a copy of bad frames, even if dropped later
> in our stacks.
> 
> GRO layer is not allowed to drop a frame, even if not 'correct'.

What do you think the accelerated hardware does with frames that have a
truncated VLAN tag?

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
