From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [PATCH v4 1/3] ixgbe, ixgbevf: Add new mbox API to enable MC
 promiscuous mode
Date: Fri, 10 Apr 2015 15:54:37 -0700
Message-ID: <1428706477.2729.125.camel@jtkirshe-mobl>
References: <7F861DC0615E0C47A872E6F3C5FCDDBD05E7EBE2@BPXM14GP.gisp.nec.co.jp>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-OmcG7JjBTsra5Jipns4S"
Cc: Alexander Duyck <alexander.duyck@gmail.com>,
	intel-wired-lan <intel-wired-lan@lists.osuosl.org>,
	Or Gerlitz <gerlitz.or@gmail.com>,
	"vyasevic@redhat.com" <vyasevic@redhat.com>,
	"e1000-devel@lists.sourceforge.net"
	<e1000-devel@lists.sourceforge.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"Choi, Sy Jong" <sy.jong.choi@intel.com>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	David Laight <David.Laight@aculab.com>,
	Hayato Momma <h-momma@ce.jp.nec.com>,
	Edward Cree <ecree@solarflare.com>,
	=?ISO-8859-1?Q?Bj=F8rn?= Mork <bjorn@mork.no>
To: Hiroshi Shimamoto <h-shimamoto@ct.jp.nec.com>,
	Phillip Schmitt <phillip.j.schmitt@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:43551 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932343AbbDJWy5 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 10 Apr 2015 18:54:57 -0400
In-Reply-To: <7F861DC0615E0C47A872E6F3C5FCDDBD05E7EBE2@BPXM14GP.gisp.nec.co.jp>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-OmcG7JjBTsra5Jipns4S
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Fri, 2015-04-10 at 01:04 +0000, Hiroshi Shimamoto wrote:
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
> promiscuous mode is enabled the VF can receive all multicast packets.
>=20
> With this patch, the ixgbevf driver automatically enable multicast
> promiscuous mode when the number of multicast addresses is over than
> 30
> if possible.
>=20
> Signed-off-by: Hiroshi Shimamoto <h-shimamoto@ct.jp.nec.com>
> Reviewed-by: Hayato Momma <h-momma@ce.jp.nec.com>
> CC: Choi, Sy Jong <sy.jong.choi@intel.com>
> ---
>  drivers/net/ethernet/intel/ixgbe/ixgbe.h          |  1 +
>  drivers/net/ethernet/intel/ixgbe/ixgbe_mbx.h      |  2 +
>  drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.c    | 76
> +++++++++++++++++++++++
>  drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c |  3 +
>  drivers/net/ethernet/intel/ixgbevf/mbx.h          |  2 +
>  drivers/net/ethernet/intel/ixgbevf/vf.c           | 27 +++++++-
>  drivers/net/ethernet/intel/ixgbevf/vf.h           |  1 +
>  7 files changed, 111 insertions(+), 1 deletion(-)

Hiroshi, I have applied your 3 patch series to my queue.
--=20
git://git.kernel.org/pub/scm/linux/kernel/git/jkirsher/next-queue.git
dev-queue

--=-OmcG7JjBTsra5Jipns4S
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAABCgAGBQJVKFStAAoJEOVv75VaS+3OmFIP/0m4J8aGldbfw+dXjpoO1LAq
VF0Ew6wkDY/SreP5VAehUFv/J+DsLshK99Qoluiq5Hw9SHBhrH0z4aWQKEajU4Yi
Kwz0eSdM3fzNsS5XdzICHf5FffNe8AUslenurSNO5T+j+TwN/F6Zw8hDez2rto+A
sHYgwXbOH8Qmuu59i6UpWhERvk3C+YGl3Pb2PhPQTckLjeptEVOTy48mWth+MeMp
PQRmwdoiSMBzHLrgoNugDI6MSKAQxqV7SzJ7HoaSqdKS5VxQ50PZgGUsC4t0LKo1
mttc+kLQ6aOfB2Nnp7tTdT8+7cUXOEAXacOB8+1qwABvaAppYQ7PKEDEZjrN4X3j
kZUY/7C3OWXhCtUiTy/k9xNt714uvDmxGIAXQV4oU08MwJmwAa0gvHCHuFXTKiFK
ancNxZs7h+X4LcST6Er0RheuiByLZUlKt1mAFu1sKgs9S6g4TimB8dlaMQzdJKHC
5o0emxx2iuN20RwQ1V2i/QMfBGb6KjWSg2nAy4RCOgKwSOWxT2PiWthb9p7b5l0+
XV+C2x12DwG65hnlmeWdBKjLloKPvUBscY2Y1UlDHzarlJ6l416N7HSbrIvSKLbz
m4XU6NKTmA58Z44a3DnX5akaTcb10vn5nzVvx05b5ekBYK7euWQ65FlQYhPcwQyP
lKc/wktSswczD2nWw600
=W81C
-----END PGP SIGNATURE-----

--=-OmcG7JjBTsra5Jipns4S--
