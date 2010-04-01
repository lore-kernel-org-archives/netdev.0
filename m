From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH 3/4] xfrm: remove policy lock when accessing policy->walk.dead
Date: Thu, 01 Apr 2010 13:24:25 +0200
Message-ID: <4BB48269.7010307@trash.net>
References: <1270030626-16687-1-git-send-email-timo.teras@iki.fi>	 <1270030626-16687-5-git-send-email-timo.teras@iki.fi>	 <20100331110345.GC12845@gondor.apana.org.au>	 <1270040773.26743.12.camel@bigi>	 <20100331131131.GA13793@gondor.apana.org.au>	 <1270042092.26743.26.camel@bigi>	 <20100331135331.GB14082@gondor.apana.org.au>  <4BB37B48.5020308@trash.net> <1270057677.26743.116.camel@bigi>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
	Timo Teras <timo.teras@iki.fi>, netdev@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>
To: hadi@cyberus.ca
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:50288 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755405Ab0DALY2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 1 Apr 2010 07:24:28 -0400
In-Reply-To: <1270057677.26743.116.camel@bigi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

jamal wrote:
> On Wed, 2010-03-31 at 18:41 +0200, Patrick McHardy wrote:
> 
>> I agree with Herbert, the flush notification indicates that
>> the table is now empty, independant of its previous state.
> 
> What purpose does it serve?
> 
> As an example, if i delete an entry, the fact i deleted an entry is 
> of interest to some manager in user space for the purpose of syncing.
> If i brought a link down, same thing. If i brought a link down
> that was already down - why would that be of interest to generate
> as an event? etc.

That's true. Since both pfkey and xfrm process messages synchronously,
there shouldn't be any need for this. In fact I couldn't even find
a single keying daemon that cares about this message.
