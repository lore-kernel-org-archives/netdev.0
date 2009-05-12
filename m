From: Yury Polyanskiy <ypolyans@Princeton.EDU>
Subject: Re: [IPSEC] xfrm_state locking problem in xfrm_input.c
Date: Tue, 12 May 2009 09:32:04 -0400
Message-ID: <20090512093204.4c30478d@penta.localdomain>
References: <20090511184739.6e497f29@penta.localdomain>
	<20090512034813.GA25841@gondor.apana.org.au>
	<20090512000516.32589e1f@penta.localdomain>
	<20090511.220723.266123145.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=PGP-SHA1;
 boundary="Sig_/zfBdw.7eCO7yVQ4ABzASscW"; protocol="application/pgp-signature"
Cc: herbert@gondor.apana.org.au, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from postoffice03.Princeton.EDU ([128.112.131.174]:57093 "EHLO
	Princeton.EDU" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751002AbZELNcP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 May 2009 09:32:15 -0400
In-Reply-To: <20090511.220723.266123145.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--Sig_/zfBdw.7eCO7yVQ4ABzASscW
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable

On Mon, 11 May 2009 22:07:23 -0700 (PDT)
David Miller <davem@davemloft.net> wrote:

> >> > Note that if the locally generated packet is sent to a local ip,
> >> > dev_queue_xmit() calls loopback_xmit() and the xfrm_input() will
> >> > be called with softirqs enabled.
> >>=20
> >> dev_queue_xmit always disables BH before calling the device xmit
> >> function.  So how can this happen?
> >>=20
> >=20
> > Oops, you right. Thanks for the explanation!
>=20
> So you didn't actually hit a bug that led you to write that
> patch?
>=20
> Please state this explicitly next time, and tell us that you are
> "fixing" something based purely upon code inspection rather than
> hitting a bug yourself.
>=20

Well, I hit some bug (occasional hard lockup of the box on ipsec'ed
data transfers), and this seemed as an excellent fit, because I
frequently test it on local->local trafic. Anyways, sorry for bothering.

YP

--Sig_/zfBdw.7eCO7yVQ4ABzASscW
Content-Type: application/pgp-signature; name=signature.asc
Content-Disposition: attachment; filename=signature.asc

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.9 (GNU/Linux)

iEYEARECAAYFAkoJelQACgkQemuRe3zuqOQI1QCfYaBF+KJzPgvTpT4ntO1+tGFm
lzQAn2aYXhsacxqB+Fijwav2HVIXh2Yc
=Jp3I
-----END PGP SIGNATURE-----

--Sig_/zfBdw.7eCO7yVQ4ABzASscW--
