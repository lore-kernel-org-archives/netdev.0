From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: linux-next: manual merge of the net-next tree with the net tree
Date: Mon, 28 Apr 2014 12:53:54 +1000
Message-ID: <20140428125354.ad04d9e14a89f7f34913d79e@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: multipart/signed; protocol="application/pgp-signature";
 micalg="PGP-SHA256";
 boundary="Signature=_Mon__28_Apr_2014_12_53_54_+1000_xToPOnTx0Fm0T/3q"
Cc: linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	Tobias Klauser <tklauser@distanz.ch>,
	Vince Bridgers <vbridger@altera.com>
To: David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--Signature=_Mon__28_Apr_2014_12_53_54_+1000_xToPOnTx0Fm0T/3q
Content-Type: text/plain; charset=US-ASCII
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi all,

Today's linux-next merge of the net-next tree got a conflict in
drivers/net/ethernet/altera/altera_sgdma.c between commit 37c0ffaad214
("Altera TSE: Work around unaligned DMA receive packet issue with Altera
SGDMA") from the net tree and commit d42f157b3498 ("Altera TSE: Remove
unnecessary cast of void pointers") from the net-next tree.

I fixed it up (the former removes the code updated by the latter, so I
did that) and can carry the fix as necessary (no action is required).

--=20
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au

--Signature=_Mon__28_Apr_2014_12_53_54_+1000_xToPOnTx0Fm0T/3q
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.22 (GNU/Linux)

iQIcBAEBCAAGBQJTXcLJAAoJEMDTa8Ir7ZwV0a8P/0U5uVyGtLx3J//bX0jNnEpR
x9WzUoWwQWa81XEUbtyyBJtHW5rrZdoY3wPViuAK4PPQS/SpMvXkxhZJoQbZAS5q
qC326P84icGq9+8nW/v/NjOzApPEl+6j2dIna7KQyWkHlX0NTZzLpIFiMDElx1T0
YKPy0VzTWNsADOSrBGjmY1ZBoyhRpObq4ge7dHUJZ9nRphgGfpu2rwDIm6T+Qlt7
2G/SGGBka1h/THJLM+q054R3skqEd3B//pvLKK8ZoqnsikpX1/pQqJjQCMgwrgAg
Oe2Jdxr+meVbh+yoxfcx/AIuPXR8qPTuEE6cu0n8IQC3H5PZUPrBqdTqWlq82cXJ
8jAc4hhzmxMIA3Vtm3+vy7zeV4Yf3PDJPBU/RWHtKFlxSWZAHb5ulfITKo9F7XRn
YKLgBlTJDbtSPieiyAI7Uhk8drmY71fSLbAIwQ24KSwP+0wcDPb51V52Dw9GV7T0
+4tUaexBhxppm5eFwzKK4QSEtZMiUpIGY0fo0xhX9pzVPc3fh147/XDw+5ym/aZb
n96E5MbAyV/bbZCDoEpsWAQdXdUMzQDhmPE9vGslUMcIpsec+gj5CevEXhIrVKnH
8/QQi6frQ6YJEB/yK787ynYNIgOkzqOM0B+tV67bXiNKDZXnRRomh9g25kRstJvp
YslEjEvxgOQupEdqadOu
=chkW
-----END PGP SIGNATURE-----

--Signature=_Mon__28_Apr_2014_12_53_54_+1000_xToPOnTx0Fm0T/3q--
