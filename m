From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: use after free bug in socket code
Date: Thu, 9 Jul 2009 23:45:33 +0800
Message-ID: <20090709154533.GA27413@gondor.apana.org.au>
References: <19028.16049.907160.45293@ipc1.ka-ro>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	urs.thuermann@volkswagen.de, oliver.hartkopp@volkswagen.de
To: Lothar =?iso-8859-1?Q?Wa=DFmann?= <LW@KARO-electronics.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:52396 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1761121AbZGIPpl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 Jul 2009 11:45:41 -0400
Content-Disposition: inline
In-Reply-To: <19028.16049.907160.45293@ipc1.ka-ro>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Lothar Wa=DFmann <LW@karo-electronics.de> wrote:
>
> So, could you point me to the place where the reference count of the
> socket object is being incremented when a struct sock is associated
> with it?

It's implicit.  Anyway, you should remodel your release function
on a working protocol.

Cheers,
--=20
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
