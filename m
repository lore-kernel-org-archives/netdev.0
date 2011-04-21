From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: linux-next: build failure after merge of the final tree (net tree
 related)
Date: Fri, 22 Apr 2011 08:10:08 +1000
Message-ID: <20110422081008.e7ebab59.sfr@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: multipart/signed; protocol="application/pgp-signature";
 micalg="PGP-SHA1";
 boundary="Signature=_Fri__22_Apr_2011_08_10_08_+1000_mzJoh0CfRQIyrSfD"
Cc: linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	=?UTF-8?B?Ik1pY2hhxYIgTWlyb3PFgmF3Ig==?= <mirq-linux@rere.qmqm.pl>
To: David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <linux-next-owner@vger.kernel.org>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--Signature=_Fri__22_Apr_2011_08_10_08_+1000_mzJoh0CfRQIyrSfD
Content-Type: text/plain; charset=US-ASCII
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi all,

After merging the final tree, today's linux-next build (powerpc chrp32_defc=
onfig)
failed like this:

drivers/net/mv643xx_eth.c: In function 'port_start':
drivers/net/mv643xx_eth.c:2250: error: 'dev' undeclared (first use in this =
function)

Caused by commit aad59c431b77 ("net: mv643xx: convert to hw_features").

--=20
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au
http://www.canb.auug.org.au/~sfr/

--Signature=_Fri__22_Apr_2011_08_10_08_+1000_mzJoh0CfRQIyrSfD
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.11 (GNU/Linux)

iQEcBAEBAgAGBQJNsKtAAAoJEDMEi1NhKgbsFCUIAJVtutRgtnWi6n8V3d5gcFKY
DAEX7Ak+0aCEHIa24yhtbOimAK3BoklLGbyo2aZEkNfVi15qlvxeVYa3WnA4vzFh
ZmDcXVST29DP0b6AKMBQ5N6s7P2srRHSMv2izxnQjBG8u8FfjY44bgF0ih0xU66/
5wmq4sYc4y3r29XadeLhK/Lbxd5AUfdWPbaj2/KXbCRbN6T8zZb4s0JldV++u9W7
CxF7OcMFQ8coHayccgOAEen4k1Akm4JPlURDn1I3tKBVwIchtK3W6DwgbA8xCpjt
5r1PmBZoIqZpcBqortujXG/P5V+DFDiqD+HQ0Z7Kk0amfkfSGwOLYWoWJdnHTDs=
=xYoE
-----END PGP SIGNATURE-----

--Signature=_Fri__22_Apr_2011_08_10_08_+1000_mzJoh0CfRQIyrSfD--
