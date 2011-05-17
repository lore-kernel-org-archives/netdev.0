From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: tap/bridge: Dropping NETIF_F_GSO/NETIF_F_SG
Date: Tue, 17 May 2011 15:24:01 +1000
Message-ID: <20110517052401.GA15198@gondor.apana.org.au>
References: <20110516121857.GA4495@gondor.apana.org.au> <BANLkTi=7i=AQfPNBEGcLFieaO9wXgBk6rg@mail.gmail.com> <20110516224658.GA11157@gondor.apana.org.au> <20110516.190615.2121423692228640268.davem@davemloft.net> <20110516234538.GA11832@gondor.apana.org.au> <20110517051845.GA26414@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, mirqus@gmail.com,
	shanwei@cn.fujitsu.com, mirq-linux@rere.qmqm.pl,
	netdev@vger.kernel.org, bhutchings@solarflare.com
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from helcar.apana.org.au ([209.40.204.226]:40904 "EHLO
	fornost.hengli.com.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751221Ab1EQFYQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 May 2011 01:24:16 -0400
Content-Disposition: inline
In-Reply-To: <20110517051845.GA26414@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, May 17, 2011 at 08:18:45AM +0300, Michael S. Tsirkin wrote:
>
> Hmm, we get the warnings about bits dropped on each set_offload
> call:
> 	netdev_update_features is called,
> 	that calls netdev_fix_features
> 
> No?

I presume this has changed recently as the current Linus tree
does not contain a call to netdev_update_features, it only calls
netdev_features_change.

If so then this does ensure that the feature bits will be sane.

I still think the warnings should be retained at their previous
level in the call paths other than set_offload.  All we have to
do is add a parameter to netdev_update_features and co.

Cheers,
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
