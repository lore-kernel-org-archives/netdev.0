From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: tap/bridge: Dropping NETIF_F_GSO/NETIF_F_SG
Date: Tue, 17 May 2011 08:46:58 +1000
Message-ID: <20110516224658.GA11157@gondor.apana.org.au>
References: <20110505100506.GA20111@gondor.apana.org.au> <20110516073210.GB6610@redhat.com> <20110516080702.GA1857@gondor.apana.org.au> <20110516081841.GA8073@redhat.com> <20110516093822.GA2779@gondor.apana.org.au> <20110516094821.GA9427@redhat.com> <20110516104309.GA3534@gondor.apana.org.au> <20110516112133.GA11274@redhat.com> <20110516121857.GA4495@gondor.apana.org.au> <BANLkTi=7i=AQfPNBEGcLFieaO9wXgBk6rg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "Michael S. Tsirkin" <mst@redhat.com>,
	Shan Wei <shanwei@cn.fujitsu.com>,
	=?utf-8?B?TWljaGHFgiBNaXJvc8WCYXc=?= <mirq-linux@rere.qmqm.pl>,
	netdev@vger.kernel.org, Ben Hutchings <bhutchings@solarflare.com>
To: =?utf-8?B?TWljaGHFgiBNaXJvc8WCYXc=?= <mirqus@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from helcar.apana.org.au ([209.40.204.226]:45999 "EHLO
	fornost.hengli.com.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754465Ab1EPWrL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 May 2011 18:47:11 -0400
Content-Disposition: inline
In-Reply-To: <BANLkTi=7i=AQfPNBEGcLFieaO9wXgBk6rg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, May 16, 2011 at 02:24:19PM +0200, Micha=C5=82 Miros=C5=82aw wro=
te:
>
> In this case - no. Those messages inform that driver supports more
> feature combinations than network core and the feature set is reduced
> because of that.

The driver should never even claim to support SG/TSO/UFO if it
does not support checksum.  That is the point of the warning.

Cheers,
--=20
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
