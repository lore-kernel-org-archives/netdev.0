From: Pavel Machek <pavel@ucw.cz>
Subject: Re: [PATCH] bluetooth.h: __ variants of u8 and friends are not
 neccessary inside kernel
Date: Thu, 6 Oct 2016 00:13:17 +0200
Message-ID: <20161005221317.GA21551@amd>
References: <20161003085640.GA8130@amd>
 <368810F9-519C-44B5-85D4-1815273438BF@holtmann.org>
 <1475689996.6105.11.camel@perches.com>
 <20161005191103.GA25972@amd>
 <1475694934.1941.1.camel@perches.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
        protocol="application/pgp-signature"; boundary="jI8keyz6grp/JLjh"
Cc: Marcel Holtmann <marcel@holtmann.org>,
        "Gustavo F. Padovan" <gustavo@padovan.org>,
        Johan Hedberg <johan.hedberg@gmail.com>,
        "David S. Miller" <davem@davemloft.net>,
        linux-bluetooth@vger.kernel.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: Joe Perches <joe@perches.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1475694934.1941.1.camel@perches.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--jI8keyz6grp/JLjh
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Wed 2016-10-05 12:15:34, Joe Perches wrote:
> On Wed, 2016-10-05 at 21:11 +0200, Pavel Machek wrote:
> > On Wed 2016-10-05 10:53:16, Joe Perches wrote:
> > > On Wed, 2016-10-05 at 13:14 +0200, Marcel Holtmann wrote:
> > > > Hi Pavel,
> > > >=20
> > > > > bluetooth.h is not part of user API, so __ variants are not necce=
ssary
> > > > > here.
> > > > >=20
> > > > > Signed-off-by: Pavel Machek <pavel@ucw.cz>
> > > > >=20
> > > > > diff --git a/include/net/bluetooth/bluetooth.h b/include/net/blue=
tooth/bluetooth.h
> > >=20
> > > []
> > > > > struct bt_skb_cb {
> > > > > -	__u8 pkt_type;
> > > > > -	__u8 force_active;
> > > > > -	__u16 expect;
> > > > > -	__u8 incoming:1;
> > > > > +	u8 pkt_type;
> > > > > +	u8 force_active;
> > > > > +	u16 expect;
> > > > > +	u8 incoming:1;
> > > > > 	union {
> > > > > 		struct l2cap_ctrl l2cap;
> > > > > 		struct hci_ctrl hci;
> > >=20
> > >=20
> > > trivia:
> > >=20
> > > It's generally faster to use bool instead of u8 foo:1;
> >=20
> > Ok, but I'm not changing that in this patch.
> > (And actually, bool will take a lot more memory, right?)
>=20
> No worries, and bool is the same size as u8.

Exactly what I'm talking about :-). One byte vs. one bit, right?

									Pavel

--=20
(english) http://www.livejournal.com/~pavelmachek
(cesky, pictures) http://atrey.karlin.mff.cuni.cz/~pavel/picture/horses/blo=
g.html

--jI8keyz6grp/JLjh
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iEYEARECAAYFAlf1ev0ACgkQMOfwapXb+vLu9wCdHXd51I2rgJXzQ4K2Jh4RsF8m
Pu0Ani1knE7JZVTbaDAl1aHgvTsaUtG1
=Qn1n
-----END PGP SIGNATURE-----

--jI8keyz6grp/JLjh--
