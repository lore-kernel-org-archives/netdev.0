From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: linux-next: manual merge of the tty tree with the net tree
Date: Tue, 27 Apr 2010 13:57:06 +1000
Message-ID: <20100427135706.259fa9c9.sfr@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: multipart/signed; protocol="application/pgp-signature";
 micalg="PGP-SHA1";
 boundary="Signature=_Tue__27_Apr_2010_13_57_06_+1000_mrs_nB.6EH/=Uo7u"
Cc: linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	Sjur Braendeland <sjur.brandeland@stericsson.com>,
	David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>,
	Pavan Savoy <pavan_savoy@ti.com>
To: Greg KH <greg@kroah.com>
Return-path: <linux-next-owner@vger.kernel.org>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--Signature=_Tue__27_Apr_2010_13_57_06_+1000_mrs_nB.6EH/=Uo7u
Content-Type: text/plain; charset=US-ASCII
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi Greg,

Today's linux-next merge of the tty tree got a conflict in
include/linux/tty.h between commit
9b27105b4a44c54bf91ecd7d0315034ae75684f7 ("net-caif-driver: add CAIF
serial driver (ldisc)") from the net tree and commit
f3150d54db0e0caa1871f66b2424f463a34a7e7b ("serial: TTY: new ldiscs for
staging") from the tty tree.

I fixed it up (they both changed NR_LDISCS - I used the higher number) and
can carry the fix as necessary.
--=20
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au
http://www.canb.auug.org.au/~sfr/

--Signature=_Tue__27_Apr_2010_13_57_06_+1000_mrs_nB.6EH/=Uo7u
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.10 (GNU/Linux)

iEYEARECAAYFAkvWYJIACgkQjjKRsyhoI8znEwCeNAyEj5U/jSsfPK61aBxC4pfU
LuUAniauKxZCc2BASpKTjP9dfpj6htaH
=sh/J
-----END PGP SIGNATURE-----

--Signature=_Tue__27_Apr_2010_13_57_06_+1000_mrs_nB.6EH/=Uo7u--
