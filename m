From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [PATCH v2] tcp: splice as many packets as possible at once
Date: Tue, 20 Jan 2009 11:01:44 +0000
Message-ID: <20090120110144.GB17004@ff.dom.local>
References: <20090114.012919.117682429.davem@davemloft.net> <20090115230331.GB1123@1wt.eu> <20090115231934.GA8328@gondor.apana.org.au> <20090115.152608.89323697.davem@davemloft.net> <20090120083726.GA13806@ff.dom.local> <20090120093352.GB13806@ff.dom.local> <20090120100043.GA9167@ioremap.net> <20090120102053.GA17004@ff.dom.local> <20090120103122.GC9167@ioremap.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, herbert@gondor.apana.org.au,
	w@1wt.eu, dada1@cosmosbay.com, ben@zeus.com, mingo@elte.hu,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	jens.axboe@oracle.com
To: Evgeniy Polyakov <zbr@ioremap.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ug-out-1314.google.com ([66.249.92.174]:6169 "EHLO
	ug-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757215AbZATLBw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Jan 2009 06:01:52 -0500
Content-Disposition: inline
In-Reply-To: <20090120103122.GC9167@ioremap.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jan 20, 2009 at 01:31:22PM +0300, Evgeniy Polyakov wrote:
> On Tue, Jan 20, 2009 at 10:20:53AM +0000, Jarek Poplawski (jarkao2@gmail.com) wrote:
> > Good question! Alas I can't check this soon, but if it's really like
> > this, of course this needs some better idea and rework. (BTW, I'd like
> > to prevent here as much as possible some strange activities like 1
> > byte (payload) packets getting full pages without any accounting.)
> 
> I believe approach to meet all our goals is to have own network memory
> allocator, so that each skb could have its payload in the fragments, we
> would not suffer from the heavy fragmentation and power-of-two overhead
> for the larger MTUs, have a reserve for the OOM condition and generally
> do not depend on the main system behaviour.

100% right! But I guess we need this current fix for -stable, and I'm
a bit worried about safety.

> 
> I will resurrect to some point my network allocator to check how things
> go in the modern environment, if no one will beat this idea first :)

I can't see too much beating of ideas around this problem now... I Wish
you luck!

> 
> 1. Network (tree) allocator
> http://www.ioremap.net/projects/nta
> 

Great, I'll try to learn a bit btw.,
Jarek P.
