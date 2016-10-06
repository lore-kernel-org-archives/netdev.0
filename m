From: Pavel Machek <pavel@ucw.cz>
Subject: Re: [PATCH] bluetooth.h: __ variants of u8 and friends are not
 neccessary inside kernel
Date: Thu, 6 Oct 2016 09:02:38 +0200
Message-ID: <20161006070237.GB25972@amd>
References: <20161003085640.GA8130@amd>
 <368810F9-519C-44B5-85D4-1815273438BF@holtmann.org>
 <1475689996.6105.11.camel@perches.com>
 <20161005191103.GA25972@amd>
 <1475694934.1941.1.camel@perches.com>
 <20161005221317.GA21551@amd>
 <1475706531.1941.4.camel@perches.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
        protocol="application/pgp-signature"; boundary="wq9mPyueHGvFACwf"
Cc: Marcel Holtmann <marcel@holtmann.org>,
        "Gustavo F. Padovan" <gustavo@padovan.org>,
        Johan Hedberg <johan.hedberg@gmail.com>,
        "David S. Miller" <davem@davemloft.net>,
        linux-bluetooth@vger.kernel.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: Joe Perches <joe@perches.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1475706531.1941.4.camel@perches.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--wq9mPyueHGvFACwf
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Wed 2016-10-05 15:28:51, Joe Perches wrote:
> On Thu, 2016-10-06 at 00:13 +0200, Pavel Machek wrote:
> > On Wed 2016-10-05 12:15:34, Joe Perches wrote:
> > > On Wed, 2016-10-05 at 21:11 +0200, Pavel Machek wrote:
> > > > On Wed 2016-10-05 10:53:16, Joe Perches wrote:
> []
> > > > > trivia:
> > > > > It's generally faster to use bool instead of u8 foo:1;
> > > > Ok, but I'm not changing that in this patch.
> > > > (And actually, bool will take a lot more memory, right?)
> > > No worries, and bool is the same size as u8.
> > Exactly what I'm talking about :-). One byte vs. one bit, right?
>=20
> Memory isn't bit addressable.
> So it's the same byte, it just doesn't use a read/modify/write
> operation to update a value.

I believe you are wrong. bit addressability does not matter, cpu can
definitely get the bit values.

u8 foo:1;
u8 bar:1;
u8 baz:1;

should take 1 byte, where

bool foo, bar, baz;

will take more like 3.

									Pavel
--=20
(english) http://www.livejournal.com/~pavelmachek
(cesky, pictures) http://atrey.karlin.mff.cuni.cz/~pavel/picture/horses/blo=
g.html

--wq9mPyueHGvFACwf
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iEYEARECAAYFAlf19w0ACgkQMOfwapXb+vIjTwCfQF2+aVCS+5vR9w4Q6m1MMwu0
egsAoIkMUy2WHLNuvkQTYnR42lNJLUoy
=jFQX
-----END PGP SIGNATURE-----

--wq9mPyueHGvFACwf--
