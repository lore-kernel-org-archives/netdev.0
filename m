From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: tap/bridge: Dropping NETIF_F_GSO/NETIF_F_SG
Date: Mon, 16 May 2011 10:32:10 +0300
Message-ID: <20110516073210.GB6610@redhat.com>
References: <20110504181813.GA17547@redhat.com>
 <20110504223415.GA14819@gondor.apana.org.au>
 <20110504232854.GA11687@rere.qmqm.pl>
 <20110505084428.GB17647@redhat.com>
 <4DC26F33.8010700@cn.fujitsu.com>
 <20110505100506.GA20111@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Shan Wei <shanwei@cn.fujitsu.com>,
	=?utf-8?B?TWljaGHFgiBNaXJvc8WCYXc=?= <mirq-linux@rere.qmqm.pl>,
	netdev@vger.kernel.org, Ben Hutchings <bhutchings@solarflare.com>
To: Herbert Xu <herbert@gondor.hengli.com.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:15982 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751460Ab1EPHcK (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 16 May 2011 03:32:10 -0400
Content-Disposition: inline
In-Reply-To: <20110505100506.GA20111@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, May 05, 2011 at 08:05:06PM +1000, Herbert Xu wrote:
> On Thu, May 05, 2011 at 05:34:43PM +0800, Shan Wei wrote:
> >
> > TUN_F_TSO4, TUN_F_TSO6, TUN_F_TSO_ECN, TUN_F_UFO these features are 
> > depend on NETIF_F_SG. If NETIF_F_SG is not set, these features are not be
> > enabled and  warnings are printed in netdev_fix_features().
> 
> No, when the user turns off checksum offload everything should
> be turned off as well.  However, when it's turned on, we shouldn't
> enable everything automatically.
> 
> Cheers,

So how is NETIF_F_SG supposed to be enabled then?

In upstream kernels userspace can disable checksum offloading then
re-enable and get SG set back.  userspace came to depend on this
behaviour so I think changing this is a regression.


> -- 
> Email: Herbert Xu <herbert@gondor.apana.org.au>
> Home Page: http://gondor.apana.org.au/~herbert/
> PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
