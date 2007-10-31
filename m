From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH]: Fix networking scatterlist regressions.
Date: Tue, 30 Oct 2007 23:44:58 -0700 (PDT)
Message-ID: <20071030.234458.123907600.davem@davemloft.net>
References: <20071030.204002.193703502.davem@davemloft.net>
	<200710311706.33142.rusty@rustcorp.com.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, herbert@gondor.apana.org.au,
	jens.axboe@oracle.com
To: rusty@rustcorp.com.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:45481
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751303AbXJaGo7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 31 Oct 2007 02:44:59 -0400
In-Reply-To: <200710311706.33142.rusty@rustcorp.com.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Rusty Russell <rusty@rustcorp.com.au>
Date: Wed, 31 Oct 2007 17:06:32 +1100

> On Wednesday 31 October 2007 14:40:02 David Miller wrote:
> > I just checked the following bug fix into net-2.6
> >
> > Rusty, have a quick look at virtio_net wrt. the changes I
> > made to skb_to_sgvec()'s behavior.  I think I might have
> > even fixed something :-)
> 
> Grr, the scatterlist changes are really pissing me off.  We get ugly tricky 
> code *and* transition pain.
> 
> I hate to suggest this, but I don't supposed there's a chance we can revert it 
> for 2.6.24 and do something cleaner for 2.6.25?

I will hit you on the head with a hammer if this happens after all
the debugging and work I've put into fixing things so far. :-/

Just like this: Plonk!
