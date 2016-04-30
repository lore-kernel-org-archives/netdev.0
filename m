From: Ben Hutchings <ben@decadent.org.uk>
Subject: Re: [PATCH 3.2 085/115] veth: =?UTF-8?Q?don=E2=80=99t?= modify
 ip_summed; doing so treats packets with bad checksums as good.
Date: Sat, 30 Apr 2016 21:18:04 +0200
Message-ID: <1462043884.17662.7.camel@decadent.org.uk>
References: <lsq.1461711744.699003961@decadent.org.uk>
	 <5720E1F0.9010203@candelatech.com>
	 <1461780469.5102.0.camel@decadent.org.uk>
	 <1461801603.3971874.591751457.2DB91B98@webmail.messagingengine.com>
	 <572155F4.10405@candelatech.com>
	 <20160428102953.GA7656@bistromath.localdomain>
	 <5722140E.80702@candelatech.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-llYl7b5xpvvmwis5NeY8"
Cc: Hannes Frederic Sowa <hannes@stressinduktion.org>,
	linux-kernel@vger.kernel.org, stable@vger.kernel.org,
	akpm@linux-foundation.org, "David S. Miller" <davem@davemloft.net>,
	Vijay Pandurangan <vijayp@vijayp.ca>,
	Cong Wang <cwang@twopensource.com>, netdev@vger.kernel.org,
	Evan Jones <ej@evanjones.ca>,
	Nicolas Dichtel <nicolas.dichtel@6wind.com>,
	Phil Sutter <phil@nwl.cc>,
	Toshiaki Makita <makita.toshiaki@lab.ntt.co.jp>,
	xiyou.wangcong@gmail.com
To: Ben Greear <greearb@candelatech.com>,
	Sabrina Dubroca <sd@queasysnail.net>
Return-path: <stable-owner@vger.kernel.org>
In-Reply-To: <5722140E.80702@candelatech.com>
Sender: stable-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--=-llYl7b5xpvvmwis5NeY8
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Thu, 2016-04-28 at 06:45 -0700, Ben Greear wrote:
>=20
> On 04/28/2016 03:29 AM, Sabrina Dubroca wrote:
[...]
> > Your use case is invalid, it just happened to work because of a
> > bug.=C2=A0=C2=A0If you want the stack to fill checksums so that you wan=
t capture
> > and reinject packets, you have to disable checksum offloading (or
> > compute the checksum yourself in userspace).
> Disabling checksum offloading or computing in user-space (and then
> recomputing in veth to verify the checksum?) is a huge performance loss.
>=20
> Maybe we could add a socket option to enable Cong's patch on a per-socket
> basis?=C2=A0=C2=A0That way my use-case can still work and you can have th=
is new
> behaviour by default?

It does sound like a useful option to have. =C2=A0If there are other
applications that depend on veth's checksum-fixing behaviour and are
being distributed in binary form, then a per-device option might be
necessary so users can keep those applications working before they're
updated.

Ben.

--=20
Ben Hutchings
Tomorrow will be cancelled due to lack of interest.
--=-llYl7b5xpvvmwis5NeY8
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAABCgAGBQJXJQTsAAoJEOe/yOyVhhEJdsIP/3erTuDrsRZy0r5zIaSReJGT
hCXyg+G+YIpGfHcPA8/US8P3cAespJyplKzIsxAYIQq84rMVVefWqYuF05Ctr1Yx
7vhLUvc5qWPLksVkNHMAfIUSl7nj2a1rZbFMfRg4+2El61Icvd8EHGfdqMH5PldA
nHWV2mlM6M95reO7ilgbNu7OwgCKGmbcxRgn6tOABFNR7rnUGbk2Yq45oy7H3Ny5
cX5NtFt+CvmTDpva5ENAg9T8d7qzBtaCtMy+wd7lmD2herw+smIZbyoPFcTe+mmU
e8CEzYQMWAsbo/OpoOOadAt5ojOHjV0/WQ2onuYzqzHsFhL/x/tplnECvjrMsPrK
UofsCKow9s+B6mUW08QIgD/gD9wBUZuMSALip5qisfbkWK26Mzyk62rnqbvxx8N2
Pxq0EFVJ+kMMlXbUzMDajXPDRgo1Xsy3+V7tE8T/qgOQ5iOzA31xXOr9h9ViSit2
v6p4aCgvH5pMoTdysW2r5cFJdW8P2dV5VmCgf9yF/WNSnJiQ5coHDpqGLsqiwFhL
REr7CQN3YWRs9JOopLnrljg/5RG157GJb4mVXbsJlNs7eNFktm9KQVATuO+XsAeY
uQQFL2SYLNJCUZUkqMawme4tME6Gq5M7chsPKJFxLk2iXmUwKcO46t572ZjDQKrR
DKlCNNg11e9XpZ1DsGWs
=msz9
-----END PGP SIGNATURE-----

--=-llYl7b5xpvvmwis5NeY8--
