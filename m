From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: linux-next: build failure after merge of the net tree
Date: Mon, 4 Apr 2011 11:28:40 +1000
Message-ID: <20110404112840.98dd98ec.sfr@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: multipart/signed; protocol="application/pgp-signature";
 micalg="PGP-SHA1";
 boundary="Signature=_Mon__4_Apr_2011_11_28_40_+1000_TRIzr_hPG=w3TB05"
Cc: linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	=?UTF-8?B?Ik1pY2hhxYIgTWlyb3PFgmF3Ig==?= <mirq-linux@rere.qmqm.pl>
To: David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <linux-next-owner@vger.kernel.org>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--Signature=_Mon__4_Apr_2011_11_28_40_+1000_TRIzr_hPG=w3TB05
Content-Type: text/plain; charset=US-ASCII
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi all,

After merging the net tree, today's linux-next build (x86_64 allmodconfig)
failed like this:

drivers/net/xen-netfront.c:1151: error: 'xennet_fix_features' undeclared he=
re (not in a function)
drivers/net/xen-netfront.c:1152: error: 'xennet_set_features' undeclared he=
re (not in a function)

Caused by commit fb507934fd6f ("net: convert xen-netfront to hw_features").

I have used the net tree from next-20110401 for today.
--=20
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au

--Signature=_Mon__4_Apr_2011_11_28_40_+1000_TRIzr_hPG=w3TB05
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.11 (GNU/Linux)

iQEcBAEBAgAGBQJNmR7IAAoJEDMEi1NhKgbsHnAIAIuC7cvVgBDHVyuCtkU12Ab1
MOZgJa+NylvIlcEYJWEhWqSVIZJ+skiOiMUJlu4fSRzAuiRhkPzXodinKnG6ZPSy
2/eMiAcLV681aWBV5RPLkwcUohihePOwzyTpdAx7bymSlIbCo5jBwpKnsHuqyWxk
KoK/tCQ91SCVwzDv1SM0A/Lv7pGULHqNP6Vo8JhiEt10MAYu+LCCMkfTT+3Zgkau
FzAH53oMyuwpbzYgLAcEJzJDikrd1bsZwJi23v/lSKoaF3BfwuKc6N2BiMxGxJ+J
9h4JETPIEvsneMoxnGUWBOnfGrLS6yp2tmDTJyH4/cSFj20WsOJSsptXkIoqz3g=
=ZzEE
-----END PGP SIGNATURE-----

--Signature=_Mon__4_Apr_2011_11_28_40_+1000_TRIzr_hPG=w3TB05--
