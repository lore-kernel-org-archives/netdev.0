From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [PATCH] ixgbe: reduce PTP rx path overhead
Date: Thu, 25 Oct 2012 00:35:12 -0700
Message-ID: <1351150512.2141.0.camel@jtkirshe-mobl>
References: <1351091846-17677-1-git-send-email-jbenc@redhat.com>
Reply-To: jeffrey.t.kirsher@intel.com
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-xC4oJIxI7kzaBaEQraie"
Cc: netdev@vger.kernel.org, e1000-devel@lists.sourceforge.net,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	John Ronciak <john.ronciak@intel.com>,
	Andy Gospodarek <gospo@redhat.com>
To: Jiri Benc <jbenc@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:20642 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758404Ab2JYHf0 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 25 Oct 2012 03:35:26 -0400
In-Reply-To: <1351091846-17677-1-git-send-email-jbenc@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-xC4oJIxI7kzaBaEQraie
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Wed, 2012-10-24 at 17:17 +0200, Jiri Benc wrote:
> Hw timestamping code caused performance regression in ixgbe driver
> when the
> timestamping is not enabled. The culprit is IXGBE_READ_REG call in the
> rx
> path which is executed for every received skb. This call is not needed
> when
> the timestamping is disabled or for non-ptp packets.
>=20
> netperf results:
>=20
> The ixge side of the connection was acting as a server, the netperf
> command
> line on the other side was:
> netperf -H 192.168.1.23 -T0,0 -t UDP_STREAM -l 20
>=20
> The values below mean throughput as reported by netperf
> (local/remote), for
> 3 runs, with timestamping not enabled.
>=20
> 3.7.0-rc1+ with CONFIG_IXGBE_PTP off:
> 5373.83 / 3329.32
> 5721.88 / 3033.89
> 5653.42 / 3112.38
>=20
> 3.7.0-rc1+ with CONFIG_IXGBE_PTP on:
> 5233.64 / 1226.85
> 5448.67 / 1039.32
> 5421.36 / 1095.66
>=20
> Patched 3.7.0-rc1+ with CONFIG_IXGBE_PTP on:
> 5594.72 / 2942.53
> 5428.95 / 3110.16
> 5343.56 / 3200.48
>=20
> Reported-by: Jesper Brouer <jbrouer@redhat.com>
> Signed-off-by: Jiri Benc <jbenc@redhat.com>
> Signed-off-by: Andy Gospodarek <gospo@redhat.com>
> ---
>  drivers/net/ethernet/intel/ixgbe/ixgbe_ptp.c |    6 ++++--
>  1 files changed, 4 insertions(+), 2 deletions(-)=20

Thanks Jiri, I have added the patch to my queue.

--=-xC4oJIxI7kzaBaEQraie
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.12 (GNU/Linux)

iQIcBAABCgAGBQJQiOuwAAoJEOVv75VaS+3ODC8P/2a7rrS4+FEpxBxeg+Iqwgyp
tx1E7261TxyBPbns+lNxx4EFzZWh7vXPsyGjlZAIO1e53lLrTf7H2yVYfatslRHj
bInUN1noiRuUKvlsz9/5s+xJn7HUHOr71G0vHYLU5sQRSiW7VxPbfKE4zG6v6VG4
lul1zdrnG1RJKkDGiP9+X1GHFONbBySeyfBA6bKyYcMo+GQP8uyCacRddffK9OIi
4lPEq684rtLCsXOV08QgOwZDl4WigalyNnJ35lmwSmzoP4qiIyTvu7TWHqfwccZo
xOwWgBBzItlkcKoDHZnNrXVO4erNa5DD0LpHNr5Bl3PoAzOad20iVUbNa5+RoO1g
GVtQ8f7YFTwBdkFnILEoBgH2ALIaAGjRDfEccfqlxQxf6qRAocDG48+enwmQ6eej
gXDocyb9EyBI60G/dXtjJB435v5JJKnpKOWHlz9KfFuxiy7oFMS5/idPe1V6tBsH
Rq/SbWA2CLdNaJ8CbEN6tFIzMfGSrLiFUALKfsRLXGxMk3hrvWcgV0sLheO1TgaP
iQa4WByYOmxOWTplamb0B/+xfVElDKZYHRUHeGJTltr6LWbRu6G6aeLtJDwcdM2g
90OcsMEgzxid2stohDjylWchSohPirF58ENmBVT1/n3cDspfIJt/nv0Y0k5lZhdp
+/tRh6kFXi5r82d0pYER
=AjL3
-----END PGP SIGNATURE-----

--=-xC4oJIxI7kzaBaEQraie--
