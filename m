From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: Re: linux-next: build failure after merge of the final tree (net
 tree related)
Date: Mon, 27 Jun 2011 15:35:22 +1000
Message-ID: <20110627153522.8884b125.sfr@canb.auug.org.au>
References: <20110623152535.e9ec4ad2.sfr@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: multipart/signed; protocol="application/pgp-signature";
 micalg="PGP-SHA1";
 boundary="Signature=_Mon__27_Jun_2011_15_35_22_+1000_PG1115==keTrKek0"
Cc: linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	Alexey Dobriyan <adobriyan@gmail.com>
To: David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <linux-next-owner@vger.kernel.org>
In-Reply-To: <20110623152535.e9ec4ad2.sfr@canb.auug.org.au>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--Signature=_Mon__27_Jun_2011_15_35_22_+1000_PG1115==keTrKek0
Content-Type: text/plain; charset=US-ASCII
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi all,

On Thu, 23 Jun 2011 15:25:35 +1000 Stephen Rothwell <sfr@canb.auug.org.au> =
wrote:
>
> After merging the final tree, today's linux-next build (powerpc
> allyesconfig) failed like this:
>=20
> drivers/net/can/sja1000/sja1000_of_platform.c: In function 'sja1000_ofp_r=
ead_reg':
> drivers/net/can/sja1000/sja1000_of_platform.c:61:2: error: implicit decla=
ration of function 'in_8'
> drivers/net/can/sja1000/sja1000_of_platform.c: In function 'sja1000_ofp_w=
rite_reg':
> drivers/net/can/sja1000/sja1000_of_platform.c:67:2: error: implicit decla=
ration of function 'out_8'
> drivers/net/can/sja1000/sja1000_of_platform.c: In function 'sja1000_ofp_r=
emove':
> drivers/net/can/sja1000/sja1000_of_platform.c:81:2: error: implicit decla=
ration of function 'iounmap'
> drivers/net/can/sja1000/sja1000_of_platform.c: In function 'sja1000_ofp_p=
robe':
> drivers/net/can/sja1000/sja1000_of_platform.c:113:2: error: implicit decl=
aration of function 'ioremap_nocache'
> drivers/net/can/sja1000/sja1000_of_platform.c:113:7: warning: assignment =
makes pointer from integer without a cast
>=20
> Since this file has not been changed recently, I suspect that this was
> caused by commit b7f080cfe223 ("net: remove mm.h inclusion from
> netdevice.h").
>=20
> I have left the build broken for now since it is also broken for other
> reasons.

I am still getting these, is there a fix pending?

--=20
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au
http://www.canb.auug.org.au/~sfr/

--Signature=_Mon__27_Jun_2011_15_35_22_+1000_PG1115==keTrKek0
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.11 (GNU/Linux)

iQEcBAEBAgAGBQJOCBaaAAoJEDMEi1NhKgbsBfcIAKLSIowpnsalVOdo8ytKEw3R
pok9RIOUUhXc56F26jW6Ac/v6FlHxPMWRAJITk+8o8CSvEZ5ub6dQj+Pi0UTedsP
eYGTTltE21cQstFzDP6nKf5r4ChZAxb6K+ROMCrHgInDbN+KPW/c3PoELiWOmjmS
c/wzV/a0twgnFG7UXABFcKoAjaGavbO5uvPfb5stCfQmzt9QRx8qqomCv50qh2XT
g6ByEIJLdzK6g3GMpA+J7QDnlwfehCfHH9gFEDoP/elRbi2/rDvz4rZH4d03/7ii
WAT9HKcMHfcvvZ+gw8pUzQgs2Qjk8U2izNl1va7Tspjp45pUNOniDgk4uXQym1U=
=ZBJV
-----END PGP SIGNATURE-----

--Signature=_Mon__27_Jun_2011_15_35_22_+1000_PG1115==keTrKek0--
