From: Adrian Bunk <bunk@kernel.org>
Subject: Re: [2.6 patch] ipv4/arp.c:arp_process(): remove bogus #ifdef mess
Date: Mon, 26 Nov 2007 21:25:47 +0100
Message-ID: <20071126202547.GB917@stusta.de>
References: <200711071434.52607.david-b@pacbell.net> <20071107225232.GB26163@stusta.de> <20071108033010.GF26163@stusta.de> <20071119.212639.217993660.davem@davemloft.net> <20071125163003.GC21947@stusta.de> <20071126151926.GD28022@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: David Miller <davem@davemloft.net>, david-b@pacbell.net,
	randy.dunlap@oracle.com, toralf.foerster@gmx.de,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from emailhub.stusta.mhn.de ([141.84.69.5]:34536 "EHLO
	mailhub.stusta.mhn.de" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1753848AbXKZUZ7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 26 Nov 2007 15:25:59 -0500
Content-Disposition: inline
In-Reply-To: <20071126151926.GD28022@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Nov 26, 2007 at 11:19:26PM +0800, Herbert Xu wrote:
> On Sun, Nov 25, 2007 at 04:30:03PM +0000, Adrian Bunk wrote:
> > > > 
> > > > Please look at net/ipv4/arp.c:arp_process()
> > > > 
> > > > Am I right that CONFIG_NET_ETHERNET=n and CONFIG_NETDEV_1000=y or 
> > > > CONFIG_NETDEV_10000=y will not be handled correctly there?
> > > > 
> > > > And the best solution is to nuke all #ifdef's in this function and make 
> > > > the code unconditionally available?
> > > 
> > > I think removing those specific ifdefs in arp_process()
> > > is the best option, yes.
> > 
> > Patch below.
> 
> Thanks Adrian.  Patch applied to net-2.6.
> 
> Do we need this for stable too?

Unless I'm misunderstanding the code we currently wrongly ignore 
some ARP packages based on the setting of an unrelated option, so
it seems to be a -stable candidate when it's in Linus' tree.

> Chers,

cu
Adrian

-- 

       "Is there not promise of rain?" Ling Tan asked suddenly out
        of the darkness. There had been need of rain for many days.
       "Only a promise," Lao Er said.
                                       Pearl S. Buck - Dragon Seed

