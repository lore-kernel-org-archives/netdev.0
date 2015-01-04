From: Giel van Schijndel <me@mortis.eu>
Subject: Re: [PATCH] Fix an infinite retry-loop
Date: Mon, 5 Jan 2015 00:04:17 +0100
Message-ID: <20150104230417.GH4806@salidar.dom.custoft.eu>
References: <1420394696-20099-1-git-send-email-me@mortis.eu>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="5UGlQXeG3ziZS81+"
Cc: Jitendra Kalsaria <jitendra.kalsaria@qlogic.com>,
	Ron Mercer <ron.mercer@qlogic.com>,
	"supporter:QLOGIC QLA3XXX NE..." <linux-driver@qlogic.com>,
	"open list:QLOGIC QLA3XXX NE..." <netdev@vger.kernel.org>
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1420394696-20099-1-git-send-email-me@mortis.eu>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--5UGlQXeG3ziZS81+
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Sun, Jan 04, 2015 at 19:04:55 +0100, Giel van Schijndel wrote:
> This was clearly intended as a retry-10-times loop, but due to the
> absence of code incrementing the loop-counter it was practically a
> retry-forever loop.
>=20
> Rewritten it as a for-loop as well to make the loop-counter increment
> (as well as its potential absence) easier to spot.
> ---

Forgot to:
Signed-off-by: Giel van Schijndel <me@mortis.eu>

--=20
Met vriendelijke groet,
With kind regards,
Giel van Schijndel
--
"A computer is a stupid machine with the ability to do incredibly smart
 things, while computer programmers are smart people with the ability to
 do incredibly stupid things. They are, in short, a perfect match.
  -- Bill Bryson

--5UGlQXeG3ziZS81+
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iEYEARECAAYFAlSpxvEACgkQZBYm/87l50LRDQCcCMx8dYOG+/+CiMdPjWXciVn2
YZEAoL626qFUWptTYUEd+4rRhtHFTJbF
=/mlU
-----END PGP SIGNATURE-----

--5UGlQXeG3ziZS81+--
