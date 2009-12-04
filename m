From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: linux-next: manual merge of the irda tree with the net tree
Date: Fri, 4 Dec 2009 17:18:25 +1100
Message-ID: <20091204171825.03208d04.sfr@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: multipart/signed; protocol="application/pgp-signature";
 micalg="PGP-SHA1";
 boundary="Signature=_Fri__4_Dec_2009_17_18_25_+1100_g/YtnsQ1W0lrYKL3"
Cc: linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	Joe Perches <joe@perches.com>,
	David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>,
	"Roel Kluin" <roel.kluin@gmail.com>
To: Samuel Ortiz <samuel@sortiz.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from chilli.pcug.org.au ([203.10.76.44]:40850 "EHLO smtps.tip.net.au"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751819AbZLDGSZ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 4 Dec 2009 01:18:25 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--Signature=_Fri__4_Dec_2009_17_18_25_+1100_g/YtnsQ1W0lrYKL3
Content-Type: text/plain; charset=US-ASCII
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi Samuel,

Today's linux-next merge of the irda tree got a conflict in
drivers/net/irda/irda-usb.c between commit
8e95a2026f3b43f7c3d676adaccd2de9532e8dcc ("drivers/net: Move && and || to
end of previous line") from the net tree and commit
1d71d682e1e4c6639f6c28042a1a2bc73c5e0554 ("irda: test index before read
in stir421x_patch_device()") from the irda tree.

I fixed it up (using the irda tree version) and can carry the fix as
necessary.
--=20
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au
http://www.canb.auug.org.au/~sfr/

--Signature=_Fri__4_Dec_2009_17_18_25_+1100_g/YtnsQ1W0lrYKL3
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.10 (GNU/Linux)

iEYEARECAAYFAksYqbEACgkQjjKRsyhoI8yNywCfbRVYXf4Uc5Ay6Qq9ZQo5hdo0
G3QAn30q/QSm7HCZgRPgccWPP/GXEKzs
=q0ua
-----END PGP SIGNATURE-----

--Signature=_Fri__4_Dec_2009_17_18_25_+1100_g/YtnsQ1W0lrYKL3--
