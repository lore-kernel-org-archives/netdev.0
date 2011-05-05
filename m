From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: tap/bridge: Dropping NETIF_F_GSO/NETIF_F_SG
Date: Thu, 5 May 2011 10:19:37 +1000
Message-ID: <20110505001937.GA15443@gondor.apana.org.au>
References: <20110504181813.GA17547@redhat.com> <20110504223415.GA14819@gondor.apana.org.au> <20110504232854.GA11687@rere.qmqm.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "Michael S. Tsirkin" <mst@redhat.com>, netdev@vger.kernel.org,
	Ben Hutchings <bhutchings@solarflare.com>
To: =?utf-8?B?TWljaGHFgiBNaXJvc8WCYXc=?= <mirq-linux@rere.qmqm.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from helcar.apana.org.au ([209.40.204.226]:56906 "EHLO
	fornost.hengli.com.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751175Ab1EEATn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 May 2011 20:19:43 -0400
Content-Disposition: inline
In-Reply-To: <20110504232854.GA11687@rere.qmqm.pl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, May 05, 2011 at 01:28:54AM +0200, Micha=C5=82 Miros=C5=82aw wro=
te:
>
> Whatever application is creating the tap0 device is not calling
> ioctl(TUNSETOFFLOAD) with TUN_F_CSUM set. This is userspace bug/featu=
re
> exposed by recent changes to netdev features handling.

OK, then user-space needs to be fixed.

Cheers,
--=20
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
