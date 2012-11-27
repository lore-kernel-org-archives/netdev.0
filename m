From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: linux-next: manual merge of the drop-experimental tree with the
 net-next tree
Date: Tue, 27 Nov 2012 16:45:12 +1100
Message-ID: <20121127164512.dd7265a6a41944eda37319a9@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: multipart/signed; protocol="application/pgp-signature";
 micalg="PGP-SHA256";
 boundary="Signature=_Tue__27_Nov_2012_16_45_12_+1100_YQJTKLz_/qgOSuvg"
Cc: linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	Ben Hutchings <bhutchings@solarflare.com>,
	David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>
To: Kees Cook <keescook@google.com>
Return-path: <linux-next-owner@vger.kernel.org>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--Signature=_Tue__27_Nov_2012_16_45_12_+1100_YQJTKLz_/qgOSuvg
Content-Type: text/plain; charset=US-ASCII
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi Kees,

Today's linux-next merge of the drop-experimental tree got a conflict in
net/dsa/Kconfig between commit b3422a314c27 ("dsa: Hide core config
options; make drivers select what they need") from the net-next tree and
commit b8e8d99e4ee8 ("net/dsa: remove depends on CONFIG_EXPERIMENTAL")
from the drop-experimental tree.

I fixed it up (using the net-next version as that removed
CONFIG_EXPERIMENTAL as well) and can carry the fix as necessary (no
action is required).

--=20
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au

--Signature=_Tue__27_Nov_2012_16_45_12_+1100_YQJTKLz_/qgOSuvg
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.12 (GNU/Linux)

iQIcBAEBCAAGBQJQtFNoAAoJEECxmPOUX5FEpUMQAJeQ/kE7HEFyu8HR5WoxX0n8
BfgEli7x8iVlKcXI+A5cwnelzc1pKUaPmD2LA162Yzuxzs3Gk8t5mEMehhmbPPMc
lvEK5vPiyTrotxSY2zbQNIKRmbw8iMUrKkvUa64DoHGPx3i3t2UkcSrRGtZsy/xq
QZLwozP+wgqf1z8TsstP/0WbEGmyJs/32+pg8LECmlLldCNU+imJXh6HN3Hf0BxX
SK32HffpsWCp2HDv15Pp5OdQpHOIcKx2ZFmE/OMYEDFoJXMLsqTLdCQrrV5rmmoD
Ek+2yoHNTLsdk3lox+5kkLi2z3dMFp5l07MFSO7pTaKAhSq/eTGIZJFjF8DeKiKr
dSQbYe3lXVdCMimoxDXPimFiiaToyHtOxM2xmlUHoKj25kj4hmXdcV6SjBYtrjws
qxk50h7kmzuPO52skxi9F2fwa5hDbBnFHkU3owDDAQ4ii6o7sdf40l9DLsBlGMpk
Q31ygxPJnqWkPLC9I1qVQ8clJDZUdKLhxHWtV/tzn5LKtmPZTFzhqOh+TP7aWZvd
2BppGaRUewhLMlHDk8BgA/QC14wbfFk7kbZEyA0k7EV4+qMP3brxCoepcyuwIa2K
55NvR6UmobldNzhhck/x+GMIAcPUiFem9YXOvhXWZH2Iy+7I8+5mGpdaZYl1ySIx
e8y4LadpRAEZAoOs1X/d
=+HXm
-----END PGP SIGNATURE-----

--Signature=_Tue__27_Nov_2012_16_45_12_+1100_YQJTKLz_/qgOSuvg--
