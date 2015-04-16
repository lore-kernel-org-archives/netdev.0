From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH -next 0/3] net: cap size to original frag size when
 refragmenting
Date: Thu, 16 Apr 2015 22:56:46 +0200
Message-ID: <20150416205646.GB4020@acer.localdomain>
References: <20150416052357.GA3285@acer.localdomain>
 <20150416052904.GA12648@gondor.apana.org.au>
 <1429186302.1075929.254563877.238D8F77@webmail.messagingengine.com>
 <20150416.114323.2122666447487730641.davem@davemloft.net>
 <1429200805.1141475.254665081.0E1724C4@webmail.messagingengine.com>
 <20150416204702.GA20616@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Hannes Frederic Sowa <hannes@stressinduktion.org>,
	David Miller <davem@davemloft.net>, fw@strlen.de,
	netdev@vger.kernel.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:39041 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754108AbbDPU4t (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Apr 2015 16:56:49 -0400
Content-Disposition: inline
In-Reply-To: <20150416204702.GA20616@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 17.04, Herbert Xu wrote:
> On Thu, Apr 16, 2015 at 06:13:25PM +0200, Hannes Frederic Sowa wrote:
> >
> > So currently we have one fast path, that is: we are not fragmented, we
> > get out non-fragmented, none of this code is ever touched and no
> > problem.
> > 
> > We don't want to mak this more complex, but
> 
> You should read Dave's other email where he gives you an obvious
> solution.  If you have to modify the skb then you don't have to
> worry about the original fragments.
> 
> But if you only read the skb then don't linearise it completely
> and keep the original fragments.

Yes, I was just responding to that. We need an additional member
in the skb, but then this part is quite simple.
