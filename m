From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [PATCH v2 1/3] ixgbe, ixgbevf: Add new mbox API to enable MC
 promiscuous mode
Date: Thu, 19 Feb 2015 20:04:06 -0800
Message-ID: <1424405046.2979.9.camel@jtkirshe-mobl>
References: <7F861DC0615E0C47A872E6F3C5FCDDBD05E3881B@BPXM14GP.gisp.nec.co.jp>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-JQ4hGM2HBLt3PYy/r5+F"
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
In-Reply-To: <7F861DC0615E0C47A872E6F3C5FCDDBD05E3881B@BPXM14GP.gisp.nec.co.jp>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--=-JQ4hGM2HBLt3PYy/r5+F
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Fri, 2015-02-20 at 00:59 +0000, Hiroshi Shimamoto wrote:
> From: Hiroshi Shimamoto <h-shimamoto@ct.jp.nec.com>
>=20
> The limitation of the number of multicast address for VF is not enough
> for the large scale server with SR-IOV feature.
> IPv6 requires the multicast MAC address for each IP address to handle
> the Neighbor Solicitation message.
> We couldn't assign over 30 IPv6 addresses to a single VF interface.
>=20
> The easy way to solve this is enabling multicast promiscuous mode.
> It is good to have a functionality to enable multicast promiscuous
> mode
> for each VF from VF driver.
>=20
> This patch introduces the new mbox API, IXGBE_VF_SET_MC_PROMISC, to
> enable/disable multicast promiscuous mode in VF. If multicast
> promiscuous
> mode is enabled the VF can receive all multicast packets.
>=20
> With this patch, the ixgbevf driver automatically enable multicast
> promiscuous mode when the number of multicast addresses is over than
> 30
> if possible.
>=20
> This also bump the API version up to 1.2 to check whether the API,
> IXGBE_VF_SET_MC_PROMISC is available.
>=20
> Signed-off-by: Hiroshi Shimamoto <h-shimamoto@ct.jp.nec.com>
> Reviewed-by: Hayato Momma <h-momma@ce.jp.nec.com>
> CC: Choi, Sy Jong <sy.jong.choi@intel.com>
> ---
>=20
> This patchset is against Jeff's tree.
>=20
> cfba326 e1000e: Fix 82574/82583 TimeSync errata handling for SYSTIM
> read
>=20
> The tree hasn't haven the fix of the IPv6 checksum issue yet,
> but I cherry-picked the commit and tested.
>=20
>  drivers/net/ethernet/intel/ixgbe/ixgbe.h          |  1 +
>  drivers/net/ethernet/intel/ixgbe/ixgbe_mbx.h      |  4 ++
>  drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.c    | 88
> ++++++++++++++++++++++-
>  drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c | 13 +++-
>  drivers/net/ethernet/intel/ixgbevf/mbx.h          |  4 ++
>  drivers/net/ethernet/intel/ixgbevf/vf.c           | 28 +++++++-
>  drivers/net/ethernet/intel/ixgbevf/vf.h           |  1 +
>  7 files changed, 135 insertions(+), 4 deletions(-)

I have added this to my queue, thanks!

--=-JQ4hGM2HBLt3PYy/r5+F
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAABCgAGBQJU5rI2AAoJEOVv75VaS+3OQqEP/i5PqXhj0K/Tv9XEFboCyL4P
Cx+ZDbafBmb3it1Ib2XI8Kyo1/LcwUMJgUUakIKY66Lra56JRS5S6NpI4y4acqFH
mxca5jNwvWc4t4GB1/kmjt/VvRaf1WaOsQyhYNUP3+FUTWEvj7o8JEh2HiTgbhaB
xWjxIYePD4ImuCKZZrzHIQ4WN10DCFlYBQ4zaB1kuo+/CdXxr0YmxbCMOf1+dyjn
Etarvv6DVPeDTzLzg5oRHZfeaZw9exxvLQuodzmzfT5FPKgVTFufRYVYzUWf0w1J
ykicp1z7zsYMkoSPhmGoyBmcPshADfLbvamxu/D/4oDWGt+fKb+W6cVyX7NtmtXJ
2L17244me8IabilOD7dNU+scI5/dZngQGlt2ktopG9kNAXeZxciUdZFYtLduMGsK
3b7/UTxk010+ZFmvEilMBJdgWKM3bxdI2TfRQ6iXdJkUlCd2x1z4Gu0hn2f3wCSj
JpwrA052DJ4VW4nmz3mZ1ujOUurQk7LRJez2zZPdZM1GSYIIg8MXmSOM5iXlTve7
rqEly9bRaN9FIVOkzQ8Ai+au6Wx2BJYp2Nf/NwCIplU3nxwdm8ai5eHDr3iY7g/d
row+QqXExV61dzFWbS5DrsDm3sJVZdGhA7a4nb3wgbZSFTszi3j5yvq0NjDsM6lg
G9YJy72SLZlnbZabKcys
=KXmH
-----END PGP SIGNATURE-----

--=-JQ4hGM2HBLt3PYy/r5+F--
