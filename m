From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: linux-next: manual merge of the net-next tree with Linus'  tree
Date: Thu, 12 Feb 2015 12:05:41 +1100
Message-ID: <20150212120541.679651ff@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
 boundary="Sig_/dhaht6_H=DqWYvBs.srb5/r"; protocol="application/pgp-signature"
Cc: linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Al Viro <viro@zeniv.linux.org.uk>
To: David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <linux-next-owner@vger.kernel.org>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--Sig_/dhaht6_H=DqWYvBs.srb5/r
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable

Hi all,

Today's linux-next merge of the net-next tree got a conflict in
crypto/af_alg.c between commit 9399f0c51489 ("crypto: fix
af_alg_make_sg() conversion to iov_iter") from Linus' tree and commit
750d8065d88b ("crypto: Fix regressions caused by iov_iter changes")
from the net-next tree.

I fixed it up (I used the net-next tree version (for no particular
reason)) and can carry the fix as necessary (no action is required).

--=20
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au

--Sig_/dhaht6_H=DqWYvBs.srb5/r
Content-Type: application/pgp-signature
Content-Description: OpenPGP digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAEBCAAGBQJU2/xqAAoJEMDTa8Ir7ZwVLpMQAJB5wt0CT8tyGi405w0i/UIY
+tzqaHqBJ6mU31dX4HHRyB8pxUaw2i3bW4bVn0FXRLAUcHreHuMSTdYU2gKF01Al
UuyJL5K/j46B72+62d76mf1tKSF8Vy0F3Z0Y9kmRiPL2Q+KntsSjqxIs/+ecBG7s
s+AI+UmW15mis0JNpCC/AXsqftbgQpzAcvQ9vIVYzxqmIz0ONvx4IHrNxpjvcmup
dxKdpIRmdJnDTWqVpY07IlZRXVrCpz7yetgd9HlX1GFDrE+rgrh1zPSI76AbrgZl
mYiw4Ns+BWX2GTxX9nAfFuReDqYfXwN5ZuvBfUI0R49VSARvw+GcUj0R2fEhIBcb
Wn0FtMFsTsFmH/s7szt24wd8i/BRdd5W7sHyAtTnrU1usd8iGpDr2/+k83THiyyG
g11UxOMOVvZNYVqIwDW3xVeFWoJkYwMGrBQdS+vjKMGtA5EJay73uYcg92pfvE0o
vp+79G/MCxV/+y8LpFGc53nDIaG6wFza9tVpTpRsHYN2xDPKUKFCBJRRm+YcGTeW
+JonYCQWdBMo4+LRnVPinocI3Mp/sKyOsz7TiAnO9q6trSIFWHCyeuFzHX+Yc+FL
KE9vnVUaO4sG7I9ti79WFQpJNpsPvU3QzkmAxWi5TF5xR0rjHBMlwyZpnxSHKgkt
lw1NFtdKIJyATdwyNjO9
=kqrv
-----END PGP SIGNATURE-----

--Sig_/dhaht6_H=DqWYvBs.srb5/r--
