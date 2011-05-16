From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: tap/bridge: Dropping NETIF_F_GSO/NETIF_F_SG
Date: Mon, 16 May 2011 19:38:22 +1000
Message-ID: <20110516093822.GA2779@gondor.apana.org.au>
References: <20110504181813.GA17547@redhat.com> <20110504223415.GA14819@gondor.apana.org.au> <20110504232854.GA11687@rere.qmqm.pl> <20110505084428.GB17647@redhat.com> <4DC26F33.8010700@cn.fujitsu.com> <20110505100506.GA20111@gondor.apana.org.au> <20110516073210.GB6610@redhat.com> <20110516080702.GA1857@gondor.apana.org.au> <20110516081841.GA8073@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Shan Wei <shanwei@cn.fujitsu.com>,
	=?utf-8?B?TWljaGHFgiBNaXJvc8WCYXc=?= <mirq-linux@rere.qmqm.pl>,
	netdev@vger.kernel.org, Ben Hutchings <bhutchings@solarflare.com>
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from helcar.apana.org.au ([209.40.204.226]:45003 "EHLO
	fornost.hengli.com.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753802Ab1EPJib (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 May 2011 05:38:31 -0400
Content-Disposition: inline
In-Reply-To: <20110516081841.GA8073@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, May 16, 2011 at 11:18:41AM +0300, Michael S. Tsirkin wrote:
>
> There's no interface for userspace to enable it: userspace
> only has an ioctl to enable/disable checksum offloading.
> SG is an implementation detail.

Yes there is: ethtool -K

Cheers,
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
