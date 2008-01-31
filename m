From: "Marco Berizzi" <pupilla@hotmail.com>
Subject: Re: ipcomp regression in 2.6.24
Date: Thu, 31 Jan 2008 09:37:10 +0100
Message-ID: <BAY103-DAV2CB7B0E5F92A3679E7621B2370@phx.gbl>
References: <E1JK3QD-0006hM-00@gondolin.me.apana.org.au> <BAY103-DAV204C57458B3E41DE1AA365B2360@phx.gbl> <20080131053221.GA4739@gondor.apana.org.au>
Cc: <davem@davemloft.net>, <Daniel.Beschorner@facton.com>,
	<netdev@vger.kernel.org>
To: "Herbert Xu" <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bay0-omc1-s10.bay0.hotmail.com ([65.54.246.82]:54350 "EHLO
	bay0-omc1-s10.bay0.hotmail.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754624AbYAaIhl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 31 Jan 2008 03:37:41 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Herbert Xu wrote:

> On Wed, Jan 30, 2008 at 10:14:46AM +0100, Marco Berizzi wrote:
> >
> > Sorry for bother you again.
> > I have applied to 2.6.24, but ipcomp doesn't work anyway.
> > I have patched a clean 2.6.24 tree and I did a complete
> > rebuild.
> > With tcpdump I see both the esp packets going in/out but
> > I don't see the clear packets on the interface.
>
> After testing it here it looks like there is this little typo
> which means that you can't actually use IPComp for anything
> that's not compressible :)

applied and tested to 2.6.24: ipcomp is working now.
As always, thanks a lot Herbert for fixing this.


