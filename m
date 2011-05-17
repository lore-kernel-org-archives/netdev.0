From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: tap/bridge: Dropping NETIF_F_GSO/NETIF_F_SG
Date: Tue, 17 May 2011 16:25:59 +1000
Message-ID: <20110517062559.GA15882@gondor.apana.org.au>
References: <20110516121857.GA4495@gondor.apana.org.au> <BANLkTi=7i=AQfPNBEGcLFieaO9wXgBk6rg@mail.gmail.com> <20110516224658.GA11157@gondor.apana.org.au> <20110516.190615.2121423692228640268.davem@davemloft.net> <20110516234538.GA11832@gondor.apana.org.au> <20110517051845.GA26414@redhat.com> <20110517052401.GA15198@gondor.apana.org.au> <20110517054823.GB26414@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, mirqus@gmail.com,
	shanwei@cn.fujitsu.com, mirq-linux@rere.qmqm.pl,
	netdev@vger.kernel.org, bhutchings@solarflare.com
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from helcar.apana.org.au ([209.40.204.226]:51044 "EHLO
	fornost.hengli.com.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751922Ab1EQG0M (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 May 2011 02:26:12 -0400
Content-Disposition: inline
In-Reply-To: <20110517054823.GB26414@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, May 17, 2011 at 08:48:23AM +0300, Michael S. Tsirkin wrote:
>
> You mean like bool quiet?

Yes when tun calls netdev_update_features we expect it to contain
bogus combinations so all warnings should disappear.

Everybody should still need maintain sanity.

Cheers,
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
