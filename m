From: David Miller <davem@davemloft.net>
Subject: Re: Unnecessary check in __sk_stream_mem_reclaim?
Date: Tue, 11 Jul 2006 21:32:04 -0700 (PDT)
Message-ID: <20060711.213204.67210308.davem@davemloft.net>
References: <E1G0V93-00037K-00@gondolin.me.apana.org.au>
	<5640c7e00607112017v326ebb4qcdd0a10a79df2de2@mail.gmail.com>
	<20060712043000.GB12535@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ian.mcdonald@jandi.co.nz, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:51889
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S932414AbWGLEbO (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 12 Jul 2006 00:31:14 -0400
To: herbert@gondor.apana.org.au
In-Reply-To: <20060712043000.GB12535@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Wed, 12 Jul 2006 14:30:00 +1000

> On Wed, Jul 12, 2006 at 03:17:43PM +1200, Ian McDonald wrote:
> >
> > I'm not saying the check is unneeded - just saying doing it twice is 
> > unneeded.
> 
> Right, got you this time.
> 
> I don't think we need to worry about people who use __sk_stream_mem_reclaim
> when there is a perfectly good sk_stream_mem_reclaim around.
> 
> Besides, this function has only been exported since 2004 so it's highly
> unlikely for there to be stuff out there using it.

Agreed.
