From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [PATCH v2 3/3] ixgbe: Add new ndo to allow VF multicast
 promiscuous mode
Date: Thu, 19 Feb 2015 20:04:46 -0800
Message-ID: <1424405086.2979.12.camel@jtkirshe-mobl>
References: <7F861DC0615E0C47A872E6F3C5FCDDBD05E38867@BPXM14GP.gisp.nec.co.jp>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-/cUDDvxoIkaVHW2O3+cY"
Cc: "Skidmore, Donald C" <donald.c.skidmore@intel.com>,
	"vyasevic@redhat.com" <vyasevic@redhat.com>,
	Alexander Duyck <alexander.duyck@gmail.com>,
	=?ISO-8859-1?Q?Bj=F8rn?= Mork <bjorn@mork.no>,
	"e1000-devel@lists.sourceforge.net"
	<e1000-devel@lists.sourceforge.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"Choi, Sy Jong" <sy.jong.choi@intel.com>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	David Laight <David.Laight@ACULAB.COM>,
	Hayato Momma <h-momma@ce.jp.nec.com>
To: Hiroshi Shimamoto <h-shimamoto@ct.jp.nec.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <7F861DC0615E0C47A872E6F3C5FCDDBD05E38867@BPXM14GP.gisp.nec.co.jp>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--=-/cUDDvxoIkaVHW2O3+cY
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Fri, 2015-02-20 at 01:01 +0000, Hiroshi Shimamoto wrote:
> From: Hiroshi Shimamoto <h-shimamoto@ct.jp.nec.com>
>=20
> Implements the new netdev op to allow VF multicast promiscuous mode.
>=20
> The administrator can allow to VF multicast promiscuous mode for only
> trusted VM. After allowing multicast promiscuous mode from the host,
> we can use over 30 IPv6 addresses on VM.
>  # ./ip link set dev eth0 vf 1 mc_promisc on
>=20
> When disallowing multicast promiscuous mode, we can only use 30 IPv6
> addresses.
>  # ./ip link set dev eth0 vf 1 mc_promisc off
>=20
> Signed-off-by: Hiroshi Shimamoto <h-shimamoto@ct.jp.nec.com>
> Reviewed-by: Hayato Momma <h-momma@ce.jp.nec.com>
> CC: Choi, Sy Jong <sy.jong.choi@intel.com>
> ---
>  drivers/net/ethernet/intel/ixgbe/ixgbe.h       |  1 +
>  drivers/net/ethernet/intel/ixgbe/ixgbe_main.c  |  7 ++++++
>  drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.c | 35
> ++++++++++++++++++++++++--
>  drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.h |  2 ++
>  4 files changed, 43 insertions(+), 2 deletions(-)

I have added this to my queue, thanks!

--=-/cUDDvxoIkaVHW2O3+cY
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAABCgAGBQJU5rJeAAoJEOVv75VaS+3Ocr8P/35TrMhmLEKc1uqs000qU3Av
0Uz5Hri6TQpnKx18INsNTrGrD0waI9CiIsHBUjwalms5gGdrOt7S5gHc5FjoazJQ
42myhe8mnB5sFr2UJqbFhDpK+50BKPYnKs8NJHAgqrEDGj7Ne9aygh/0N1/B9ieL
Vbh4J0tSg2TBtKHOC07Dk4+AZsY5fGZ1evN8uYxO9teAkSHchE/9qGIivNpw7vAH
O7HStx3AFj8irEo5PPHHOuqnRmkV0NeJ9AEMUHRo+6gpIXmouJiG9Mbex3pQSUKd
BoRgJ1jZD1CZAx824OAHE5SpZHHrkbFLd2V1JW6jfN91UDuItdqORpk4K2QEf50J
nayKcbvxHvbmVXd1+AQVvh5DH/dsN2Jhrbj3m0SuVq31x0G/1Oo8zQwWmHLViFLb
gnDg2IWQTF2uvZA2jRd6j1KAIl98Ph4rzLwWHnNf0fGvpCxUYGSIbbO/vxJvIPF6
Hjx4CxPz/gbgMbbGo/Jy69OqjnwlAfOSGQjTjB3yaDmxvsb+oyTPZXnxMtxo6q61
d9pZ2dkZTxHczBNmVzRfIBzcVWHmxe8sGk8YegrukatASb7qBcnW5St7f+I49IVU
jsELTNoW3mEHl2F0WRTEjD4bZXXooGOLQJ7R+YFwf4oxFCEmd/igzqOW7gWdq1ni
ABTgdETz4TPiWqMbU2iX
=E94Y
-----END PGP SIGNATURE-----

--=-/cUDDvxoIkaVHW2O3+cY--
