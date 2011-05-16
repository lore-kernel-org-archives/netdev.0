From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: tap/bridge: Dropping NETIF_F_GSO/NETIF_F_SG
Date: Mon, 16 May 2011 18:07:02 +1000
Message-ID: <20110516080702.GA1857@gondor.apana.org.au>
References: <20110504181813.GA17547@redhat.com> <20110504223415.GA14819@gondor.apana.org.au> <20110504232854.GA11687@rere.qmqm.pl> <20110505084428.GB17647@redhat.com> <4DC26F33.8010700@cn.fujitsu.com> <20110505100506.GA20111@gondor.apana.org.au> <20110516073210.GB6610@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Shan Wei <shanwei@cn.fujitsu.com>,
	=?utf-8?B?TWljaGHFgiBNaXJvc8WCYXc=?= <mirq-linux@rere.qmqm.pl>,
	netdev@vger.kernel.org, Ben Hutchings <bhutchings@solarflare.com>
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from helcar.apana.org.au ([209.40.204.226]:39394 "EHLO
	fornost.hengli.com.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752095Ab1EPIHP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 May 2011 04:07:15 -0400
Content-Disposition: inline
In-Reply-To: <20110516073210.GB6610@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, May 16, 2011 at 10:32:10AM +0300, Michael S. Tsirkin wrote:
>
> So how is NETIF_F_SG supposed to be enabled then?

It should either be enabled at device creation time, or whatever
user-space entity managing the device creation should enable it
along with checksumming and anything else applicable.

> In upstream kernels userspace can disable checksum offloading then
> re-enable and get SG set back.  userspace came to depend on this
> behaviour so I think changing this is a regression.

Can you point me to the relevant code in the upstream kernel?
I'm not aware of any automatic SG enabling for network devices
in general when you enable checksum offloading.

Cheers,
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
