From: Alex Samad <alex@samad.com.au>
Subject: Re: kernel oops when system under network stress
Date: Thu, 16 Oct 2008 16:48:33 +1100
Message-ID: <20081016054833.GA9030@samad.com.au>
References: <20081016030416.GA5551@samad.com.au> <20081015.215536.242281148.davem@davemloft.net> <20081016054159.GA4696@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="OgqxwSJOaUobr8KG"
Cc: David Miller <davem@davemloft.net>, linux-net@vger.kernel.org,
	netdev@vger.kernel.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <linux-net-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20081016054159.GA4696@gondor.apana.org.au>
Sender: linux-net-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--OgqxwSJOaUobr8KG
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Thu, Oct 16, 2008 at 01:41:59PM +0800, Herbert Xu wrote:
> On Wed, Oct 15, 2008 at 09:55:36PM -0700, David Miller wrote:
> >
> > [ Herbert, this looks like another case like that ebtables+tg3 one,
> >   where the checksum field is not set properly. ]
>=20
> Looking at the trace, I don't think ebtables plays any part since
I have more of these about 127K file

> it appears only on the receive path while the checksum problem is
> on the transmit path.
>=20
> I'm tempted to blame tg3's management of netdev feature setting

I am using forcedeth not tg3=20

> since it's far from obvious whether it enables TSOv6 only if IPv6
> checksumming is also enabled.
>=20
> Unfortunately I'm still stuck in some bog at the moment, but
> hopefully I can resume looking at this issue in a couple of days.
>=20
> Thanks,

Hi herbert, seems like I have more kernel problems for you :)

> --=20
> Visit Openswan at http://www.openswan.org/
> Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
> Home Page: http://gondor.apana.org.au/~herbert/
> PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
> --
> To unsubscribe from this list: send the line "unsubscribe linux-net" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>=20

--=20
//GO.SYSIN DD *, DOODAH, DOODAH

--OgqxwSJOaUobr8KG
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.9 (GNU/Linux)

iEYEARECAAYFAkj21bEACgkQkZz88chpJ2PzxACg4pqT+SOhI84YN4JSCSHVxF9c
gFsAn0CBi3dhzi2kKR/4vG1jXLUrN3WE
=pHMc
-----END PGP SIGNATURE-----

--OgqxwSJOaUobr8KG--
