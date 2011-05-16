From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: tap/bridge: Dropping NETIF_F_GSO/NETIF_F_SG
Date: Mon, 16 May 2011 11:28:10 +0300
Message-ID: <20110516082810.GA8252@redhat.com>
References: <20110504181813.GA17547@redhat.com>
 <20110504223415.GA14819@gondor.apana.org.au>
 <20110504232854.GA11687@rere.qmqm.pl>
 <20110505084428.GB17647@redhat.com>
 <4DC26F33.8010700@cn.fujitsu.com>
 <20110505100506.GA20111@gondor.apana.org.au>
 <20110516073210.GB6610@redhat.com>
 <20110516080702.GA1857@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Shan Wei <shanwei@cn.fujitsu.com>,
	=?utf-8?B?TWljaGHFgiBNaXJvc8WCYXc=?= <mirq-linux@rere.qmqm.pl>,
	netdev@vger.kernel.org, Ben Hutchings <bhutchings@solarflare.com>
To: Herbert Xu <herbert@gondor.hengli.com.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:31537 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751739Ab1EPI2H (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 16 May 2011 04:28:07 -0400
Content-Disposition: inline
In-Reply-To: <20110516080702.GA1857@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, May 16, 2011 at 06:07:02PM +1000, Herbert Xu wrote:
> On Mon, May 16, 2011 at 10:32:10AM +0300, Michael S. Tsirkin wrote:
> >
> > So how is NETIF_F_SG supposed to be enabled then?
> 
> It should either be enabled at device creation time, or whatever
> user-space entity managing the device creation should enable it
> along with checksumming and anything else applicable.
> 
> > In upstream kernels userspace can disable checksum offloading then
> > re-enable and get SG set back.  userspace came to depend on this
> > behaviour so I think changing this is a regression.
> 
> Can you point me to the relevant code in the upstream kernel?
> I'm not aware of any automatic SG enabling for network devices
> in general when you enable checksum offloading.
> 
> Cheers,

By the way with kvm we let an unpriveledged application
control netdev flags through and ioctl. It's probably
not a good idea to print out stuff on flag change
unconditionally as that will let that application
fill up the system log.

> -- 
> Email: Herbert Xu <herbert@gondor.apana.org.au>
> Home Page: http://gondor.apana.org.au/~herbert/
> PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
