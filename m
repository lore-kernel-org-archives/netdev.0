From: Mark Brown <broonie@kernel.org>
Subject: linux-next: manual merge of the net-next tree with the net tree
Date: Mon, 16 Oct 2017 10:36:35 +0100
Message-ID: <20171016093635.zxyyq2px4hdewse3@sirena.co.uk>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
        protocol="application/pgp-signature"; boundary="panwwdpopndhfdyb"
Cc: Linux-Next Mailing List <linux-next@vger.kernel.org>,
        Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
To: David Miller <davem@davemloft.net>,
        Networking <netdev@vger.kernel.org>,
        Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Return-path: <linux-next-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--panwwdpopndhfdyb
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi all,

Today's linux-next merge of the net-next tree got a conflict in:

  drivers/net/dsa/mv88e6060.c

between commit:

  3efc93c2bc243 ("net: dsa: mv88e6060: fix switch MAC address")

=66rom the net tree and commit:

  56c3ff9bf23e1 ("net: dsa: mv88e6060: setup random mac address")

=66rom the net-next tree.

I fixed it up (see below, the relevant code was deleted in net-next) and
can carry the fix as necessary. This is now fixed as far as linux-next
is concerned, but any non trivial conflicts should be mentioned to your
upstream maintainer when your tree is submitted for merging.  You may
also want to consider cooperating with the maintainer of the conflicting
tree to minimise any particularly complex conflicts.

diff --cc drivers/net/dsa/mv88e6060.c
index f123ed57630d,6173be889d95..000000000000
--- a/drivers/net/dsa/mv88e6060.c
+++ b/drivers/net/dsa/mv88e6060.c

--panwwdpopndhfdyb
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQEzBAABCAAdFiEEreZoqmdXGLWf4p/qJNaLcl1Uh9AFAlnkfaIACgkQJNaLcl1U
h9ACvAf8CPT/AykF7gE2NBbdP0+9H78KIRQObHfOkhqurAjBzVFicqECnQSmuZf8
qQ7CHH7ClCX/5kj/qW2Tc9DVReo27sNVgHuTe9RkjU1hMg94rHBEUByaF3F/Ly/G
vZleCdGWwqab+oDNvt68Sq2zkm3tmz8axv1pw2404SIQy4RGjKsCyy32jGPCXUmK
CQ/NTNxCFrTvigxWrJcyI038CNwy4/RSjBEvnoGYBHF3Y+hkL1mr3lcA8adt5TRM
FFyUh+1tFdxmLMJ3IjZF/mXmO60Nw4j4rx2EgQeP6sVTR3zRkwkQJLzz09U4S9UU
OzpHLLo/cECYbREAso38o+iSTVVF7A==
=88Tm
-----END PGP SIGNATURE-----

--panwwdpopndhfdyb--
