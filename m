From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: linux-next: manual merge of the staging-next tree with the net tree
Date: Fri, 23 Jul 2010 15:03:23 +1000
Message-ID: <20100723150323.daa04d5f.sfr@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: multipart/signed; protocol="application/pgp-signature";
 micalg="PGP-SHA1";
 boundary="Signature=_Fri__23_Jul_2010_15_03_23_+1000_sEdJulbjqN_KzaZL"
Cc: linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	Eric Dumazet <eric.dumazet@gmail.com>,
	David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>,
	Sven Eckelmann <sven.eckelmann@gmx.de>
To: Greg KH <greg@kroah.com>
Return-path: <linux-next-owner@vger.kernel.org>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--Signature=_Fri__23_Jul_2010_15_03_23_+1000_sEdJulbjqN_KzaZL
Content-Type: text/plain; charset=US-ASCII
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi Greg,

Today's linux-next merge of the staging-next tree got a conflict in
drivers/staging/batman-adv/hard-interface.c between commit
28172739f0a276eb8d6ca917b3974c2edb036da3 ("net: fix 64 bit counters on 32
bit arches") from the net tree and commit
a1a38cad4c71bc08403b204fbe0ba98b4447f8bf ("Staging: batman-adv: Don't
increment stats of foreign device") from the staging-next tree.

The latter just removes the code fixed by the former, so I did that.
--=20
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au
http://www.canb.auug.org.au/~sfr/

--Signature=_Fri__23_Jul_2010_15_03_23_+1000_sEdJulbjqN_KzaZL
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.10 (GNU/Linux)

iQEcBAEBAgAGBQJMSSKbAAoJEDMEi1NhKgbslIwH/1WTpz2zwBRKXsRXqAFi9odl
u6up4/NAXhZe9R974iILL37diIiO1hCQjKfql5mMCtWqqXhCNkWZ9yLIdLJmmrgG
NwLKpaCprS1p+vMRLkHyKhGar5YeGvMAPRrQt17w0ZhuUAe0jsNrLOQcdyttOqCm
jNKkCvUzloreTsZM2hdOLwGWPuFEDi4+9/YQbjtxTHI021zi6R/9QTGOe7vEauuG
+x1Ms7MQzfw+986tBeYsxirurT0PJN3GsURNpz9smcSE19WMAutbErkLSYfe8YJU
ccspHrsDrodBsniUgZ/sWIezUVjEGo740UhyTQc60cumVyGOsS9j+acOQWfd2VQ=
=urUy
-----END PGP SIGNATURE-----

--Signature=_Fri__23_Jul_2010_15_03_23_+1000_sEdJulbjqN_KzaZL--
