From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: linux-next: manual merge of the net tree with the i.MX tree
Date: Fri, 4 Mar 2011 12:31:35 +1100
Message-ID: <20110304123135.f3389022.sfr@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: multipart/signed; protocol="application/pgp-signature";
 micalg="PGP-SHA1";
 boundary="Signature=_Fri__4_Mar_2011_12_31_35_+1100_hSFvZdtrw/e5NjL="
Cc: linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	Richard Zhao <richard.zhao@freescale.com>,
	Sascha Hauer <s.hauer@pengutronix.de>,
	=?UTF-8?B?IlV3ZSBLbGVpbmUtS8O2bmlnIg==?=
	<u.kleine-koenig@pengutronix.de>
To: David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <linux-next-owner@vger.kernel.org>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--Signature=_Fri__4_Mar_2011_12_31_35_+1100_hSFvZdtrw/e5NjL=
Content-Type: text/plain; charset=US-ASCII
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi all,

Today's linux-next merge of the net tree got a conflict in
drivers/net/Kconfig between commit
4d2f13be1e370a670c1cae20c194d5ce961e0fa5 ("ARM: imx3x: clean up
ARCH_MX3X") from the i.MX tree and commit
085e79ed88351d2f3cbf257ff4fc00394792da18 (net/fec: consolidate all i.MX
options to CONFIG_ARM"") from the net tree.

The latter seems to be a superset of the former, so I used that.
--=20
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au
http://www.canb.auug.org.au/~sfr/

--Signature=_Fri__4_Mar_2011_12_31_35_+1100_hSFvZdtrw/e5NjL=
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.11 (GNU/Linux)

iQEcBAEBAgAGBQJNcED3AAoJEDMEi1NhKgbsFAwIAJHWqhRIUGaGnuk0UFZMm1X3
OJS/js8Hrxe82lyK9N5hQa/m1nehw/ONFaYUy/PIF4WKGiJ+t+kutORiYjo7Be2e
fA3BYS7mjoF5/usxQz550U9wDLFnuexifIgS0g7fKWjlbiFbogNRZXI4iYIxN1ak
mGcoyB4MomPWgYWHjPY0IUdN6dPDlQncVwI/5hV3wpRK7XJVD0OQhr2S4hlKlzq1
oEViuNw+BvLXfbM/hagrHK9LFNt8mSiHiFuDTk2bAfdkhzEgh5rmDkbu8Jcq3+iR
mhKnMPzVsgdb0GFBHk+PkvdfCWAIyJerAx+A34G0mTRfnMSRjCB+KFIzGd9a5+0=
=Xi+s
-----END PGP SIGNATURE-----

--Signature=_Fri__4_Mar_2011_12_31_35_+1100_hSFvZdtrw/e5NjL=--
