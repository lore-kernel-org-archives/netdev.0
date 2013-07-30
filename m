From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: Re: [RFC PATCH - diffstat only] include/net: Remove extern from
 function prototypes
Date: Tue, 30 Jul 2013 17:38:00 +1000
Message-ID: <20130730173800.1825a1452694f40370699413@canb.auug.org.au>
References: <1374602291.3387.17.camel@joe-AO722>
	<20130730.001001.618776305200728182.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: multipart/signed; protocol="application/pgp-signature";
 micalg="PGP-SHA256";
 boundary="Signature=_Tue__30_Jul_2013_17_38_00_+1000_4PkxiStRpVS09L2s"
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Joe Perches <joe@perches.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20130730.001001.618776305200728182.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--Signature=_Tue__30_Jul_2013_17_38_00_+1000_4PkxiStRpVS09L2s
Content-Type: text/plain; charset=US-ASCII
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi Joe,

On Tue, 30 Jul 2013 00:10:01 -0700 (PDT) David Miller <davem@davemloft.net>=
 wrote:
>
> From: Joe Perches <joe@perches.com>
> Date: Tue, 23 Jul 2013 10:58:11 -0700
>=20
> > Function prototypes don't need to be declared
> > extern in .h files.  It's assumed by the compiler
> > and is as unnecessary as using auto is when
> > declaring automatic/local variables in a block.
> >=20
> > I ran a script to remove these unnecessary extern
> > uses from function prototypes in include/net/ as
> > well as reflow the function arguments to 80 cols.
> >=20
> > It's 370KB, far too large to submit at once.
> >=20
> > Of course it could be broken into multiple patches
> > for the various directories/subsystems.
>=20
> No objections from me.

I must admit I prefer the other way (i.e. with the explicit extern).  If
nothing else it makes it consistent with variable declarations in header
files (which need the extern) and "static inlines" ...

Making these churn changes also will almost certainly cause unnecessary
conflicts :-(

--=20
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au

--Signature=_Tue__30_Jul_2013_17_38_00_+1000_4PkxiStRpVS09L2s
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.20 (GNU/Linux)

iQIcBAEBCAAGBQJR921YAAoJEECxmPOUX5FELKoP/jtHlvYP0cnc+AXstmKM+chW
L6daLbfwl1n5SDDZQuFU8EbFUgeb/P8I3GutOb4AA5RSbn3BFhNO/pna3K9e0fpe
YysbSXN+MNha/8/7539n04250IJU8qKycAFOQRpaocq3i6s/zjO5KL7KTkXBP29y
piTkkJDboQG1UAbt3lecQB5BmQagSlmfYMSl68eyGxctVfQjwKmp8YdDWaUahngD
lnBe837xNsIko3M+8LwY+OKi6k3k+W6MpLRQadnrTIxL3WRvn3SbgZ3zy7EK0TEg
gsHx76dCBNGWFoW4IHPTzr+ihtS76x86HL3XkgxsyMMHPQiqd8ldH6XZ0MQua2Wz
uujCAqEN/ghXeGbI5A3A7efoTq1Fvtuk49gRhFTowOphCkyTzucy/R+1D9mVDTwV
b1PcUcTsTejy06hjOEELkIamaMHz6bwBLbSFCgn6hi5LkRaJtxbcKbELum/pFfVL
f6jqw1uV8aOgpJckhBuLd4nGxICHhOXWWW/nr7diTfHxsX4LNHAFkVPYUsKKYbHw
7J2MEUxics4+1p2cIDSfvoann2nXQzdmU97snZhAhc9aNmxEpwafaraHrcBvHm4F
8meAkLoDNKfAheuOkjfCd6AI5mqzlUaf/tJCOqyu2OKBFxY+cgpwWVf9cHH+dd2a
CBicbP08Rg2tHb54rgH/
=PAS1
-----END PGP SIGNATURE-----

--Signature=_Tue__30_Jul_2013_17_38_00_+1000_4PkxiStRpVS09L2s--
