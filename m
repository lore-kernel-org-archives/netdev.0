From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: SO_REUSEPORT - can it be done in kernel?
Date: Tue, 1 Mar 2011 21:58:40 +0800
Message-ID: <20110301135840.GA8696@gondor.apana.org.au>
References: <20110301101955.GI9763@canuck.infradead.org> <1298975602.3284.13.camel@edumazet-laptop> <20110301110708.GJ9763@canuck.infradead.org> <1298977984.3284.15.camel@edumazet-laptop> <20110301112759.GK9763@canuck.infradead.org> <1298979909.3284.28.camel@edumazet-laptop> <20110301115305.GA6984@gondor.apana.org.au> <1298984609.3284.98.camel@edumazet-laptop> <20110301131823.GB8028@gondor.apana.org.au> <1298987566.3284.105.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Thomas Graf <tgraf@infradead.org>,
	David Miller <davem@davemloft.net>, rick.jones2@hp.com,
	therbert@google.com, wsommerfeld@google.com,
	daniel.baluta@gmail.com, netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from helcar.apana.org.au ([209.40.204.226]:34387 "EHLO
	fornost.hengli.com.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753717Ab1CAN6y (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Mar 2011 08:58:54 -0500
Content-Disposition: inline
In-Reply-To: <1298987566.3284.105.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Mar 01, 2011 at 02:52:46PM +0100, Eric Dumazet wrote:
> Le mardi 01 mars 2011 =E0 21:18 +0800, Herbert Xu a =E9crit :
>=20
> > Interesting.  So I wonder which lock is showing up at the top
> > of the profile with a single socket then.  As it's definitely
> > going away with multiple sockets, that means it's not the TX
> > queue lock.
> >=20
>=20
> This CPU also runs named process, so this is socket lock and receive
> queue lock.

It can't be the socket lock because it's an IRQ-disabling variant.
The receive queue lock, I'll buy that.

Cheers,
--=20
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
