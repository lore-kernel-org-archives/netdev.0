From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: tap/bridge: Dropping NETIF_F_GSO/NETIF_F_SG
Date: Mon, 16 May 2011 14:21:33 +0300
Message-ID: <20110516112133.GA11274@redhat.com>
References: <20110504232854.GA11687@rere.qmqm.pl>
 <20110505084428.GB17647@redhat.com>
 <4DC26F33.8010700@cn.fujitsu.com>
 <20110505100506.GA20111@gondor.apana.org.au>
 <20110516073210.GB6610@redhat.com>
 <20110516080702.GA1857@gondor.apana.org.au>
 <20110516081841.GA8073@redhat.com>
 <20110516093822.GA2779@gondor.apana.org.au>
 <20110516094821.GA9427@redhat.com>
 <20110516104309.GA3534@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Shan Wei <shanwei@cn.fujitsu.com>,
	=?utf-8?B?TWljaGHFgiBNaXJvc8WCYXc=?= <mirq-linux@rere.qmqm.pl>,
	netdev@vger.kernel.org, Ben Hutchings <bhutchings@solarflare.com>
To: Herbert Xu <herbert@gondor.hengli.com.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:30425 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750984Ab1EPLVj (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 16 May 2011 07:21:39 -0400
Content-Disposition: inline
In-Reply-To: <20110516104309.GA3534@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, May 16, 2011 at 08:43:10PM +1000, Herbert Xu wrote:
> On Mon, May 16, 2011 at 12:48:21PM +0300, Michael S. Tsirkin wrote:
> >
> > Both bridge and tun trigger the messages ATM. I note that
> > dev.c takes pains to avoid these messages:
> > 	Avoid warning from netdev_fix_features() for GSO without SG
> > 
> > Should all drivers do this: clear _SG if they clear checksum?  What about _GSO?
> > If we start doing this, this spills info about flag dependencies out to drivers.
> 
> Drivers don't need to do this at all since the network stack
> will automatically clear SG and related features if checksum
> is disabled.
> 
> Cheers,

Yes, but then we get annoying info messages every time.
Change them all to debug or remove completely?

> -- 
> Email: Herbert Xu <herbert@gondor.apana.org.au>
> Home Page: http://gondor.apana.org.au/~herbert/
> PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
