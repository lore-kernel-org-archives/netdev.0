From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: Fw: [Bug 14470] New: freez in TCP stack
Date: Fri, 30 Oct 2009 16:18:44 -0400
Message-ID: <20091030201844.GA10557@gondor.apana.org.au>
References: <alpine.DEB.2.00.0910291316340.19761@wel-95.cs.helsinki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: eric.dumazet@gmail.com, davem@davemloft.net,
	akpm@linux-foundation.org, shemminger@linux-foundation.org,
	netdev@vger.kernel.org, kolo@albatani.cz,
	bugzilla-daemon@bugzilla.kernel.org
To: Ilpo =?iso-8859-1?Q?J=E4rvinen?= <ilpo.jarvinen@helsinki.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:44637 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1754101AbZJ3US5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 30 Oct 2009 16:18:57 -0400
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.00.0910291316340.19761@wel-95.cs.helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Ilpo J=E4rvinen <ilpo.jarvinen@helsinki.fi> wrote:
>=20
> One more alternative along those lines could perhaps be:
>=20
> We enter with empty write_queue there and with the hint being null, s=
o we=20
> take the else branch... and skb_peek then gives us the NULL ptr. Howe=
ver,=20
> I cannot see how this could happen as all branches trap with return=20
> before the reach tcp_xmit_retransmit_queue.

Why don't we add a WARN_ON in there and see if it triggers?

Thanks,
--=20
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
