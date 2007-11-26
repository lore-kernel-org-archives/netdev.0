From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [2.6 patch] ipv4/arp.c:arp_process(): remove bogus #ifdef mess
Date: Mon, 26 Nov 2007 23:19:26 +0800
Message-ID: <20071126151926.GD28022@gondor.apana.org.au>
References: <200711071434.52607.david-b@pacbell.net> <20071107225232.GB26163@stusta.de> <20071108033010.GF26163@stusta.de> <20071119.212639.217993660.davem@davemloft.net> <20071125163003.GC21947@stusta.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, david-b@pacbell.net,
	randy.dunlap@oracle.com, toralf.foerster@gmx.de,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Adrian Bunk <bunk@kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:3730 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1754280AbXKZPT5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 26 Nov 2007 10:19:57 -0500
Content-Disposition: inline
In-Reply-To: <20071125163003.GC21947@stusta.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, Nov 25, 2007 at 04:30:03PM +0000, Adrian Bunk wrote:
> > > 
> > > Please look at net/ipv4/arp.c:arp_process()
> > > 
> > > Am I right that CONFIG_NET_ETHERNET=n and CONFIG_NETDEV_1000=y or 
> > > CONFIG_NETDEV_10000=y will not be handled correctly there?
> > > 
> > > And the best solution is to nuke all #ifdef's in this function and make 
> > > the code unconditionally available?
> > 
> > I think removing those specific ifdefs in arp_process()
> > is the best option, yes.
> 
> Patch below.

Thanks Adrian.  Patch applied to net-2.6.

Do we need this for stable too?

Chers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
