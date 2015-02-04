From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [E1000-devel] [PATCH 1/3] ixgbe, ixgbevf: Add new mbox API to
 enable MC promiscuous mode
Date: Wed, 04 Feb 2015 04:57:21 -0800
Message-ID: <1423054641.2589.59.camel@jtkirshe-mobl>
References: <7F861DC0615E0C47A872E6F3C5FCDDBD05E1908D@BPXM14GP.gisp.nec.co.jp>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-Hmgr7MoU8XHjGL/j+NTg"
Cc: Alexander Duyck <alexander.duyck@gmail.com>,
	"Skidmore, Donald C" <donald.c.skidmore@intel.com>,
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
In-Reply-To: <7F861DC0615E0C47A872E6F3C5FCDDBD05E1908D@BPXM14GP.gisp.nec.co.jp>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--=-Hmgr7MoU8XHjGL/j+NTg
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Fri, 2015-01-30 at 11:37 +0000, Hiroshi Shimamoto wrote:
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
>  drivers/net/ethernet/intel/ixgbe/ixgbe.h          |  1 +
>  drivers/net/ethernet/intel/ixgbe/ixgbe_mbx.h      |  4 +
>  drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.c    | 89
> ++++++++++++++++++++++-
>  drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c | 13 +++-
>  drivers/net/ethernet/intel/ixgbevf/mbx.h          |  4 +
>  drivers/net/ethernet/intel/ixgbevf/vf.c           | 29 +++++++-
>  drivers/net/ethernet/intel/ixgbevf/vf.h           |  1 +
>  7 files changed, 137 insertions(+), 4 deletions(-)

Hiroshi, I tried to apply your patches to my queue but they do not apply
cleanly and they are in a DOS file format, not UNIX.  I also noted
several checkpatch.pl issues with your patches, so please fix those up
as well.

Can you please fix up your patches based on my tree:
git://git.kernel.org/pub/scm/linux/kernel/git/jkirsher/queue.git

This my queue of all community patches against the Intel LAN drivers and
will be where I queue up your patches while they are under review and
testing.

--=-Hmgr7MoU8XHjGL/j+NTg
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAABCgAGBQJU0hcxAAoJEOVv75VaS+3O+XgQAIRPWeUehq3cOvlMcCE7EDnk
Rsv7paICOu1JvSF8RNOFm7wnxPCqGqG3ED6zEDaoFnoFq8vOitYWWx+0rRz4WhK2
EVvbedYLW8sYMp2qYSTMNQjlwe5mzRTi4bpWQnff1/EXjPd3gi8UjsK09G/jfO81
o6oqAPmDD0XbdeqJUem61QSo41d/QaY6i1brvs/iQm3WdpFNsrnWSDju5LsUjBqj
dpzyst060ZPnKPW+qtv+No0bxnqVpP5ik8xW2Hy+tEeUnrRjwsMnzRMbcy2PijOF
6Is4O5sOHyfDfDdXlCzodLcF8BCD0mIBBvLRp20EyX3WP8tzv2pUrHhoB5x+SdIZ
ejCmOjIudEa84xurhrh1LvH5Ge5+X6ockv2yW8AoF/5p7aRBlrbOs8bva2ybs1lV
Q1m/ancJUJBxBts1IDDLrquE2nWujlNnwd+urKKfWsYSiDgoUIX2DYlhUIxJcfeK
K6dN4uZP0dSVr0q1z4V+Mg/EuV16CbKVhoEsDiE2BofFC6BZWdhLdXsrBITpxZ+T
4FLTgY2EcYi9GUXZlquQCj13l4pddptNy4N+GXmzHbKzkSncRqN8lUw9YmaBrKZJ
tUIR63p64cMQwYetQKBxXjbOcT9AGstego4qYHOu6IkptAeITPAgR7u9KqnWyA/D
l4sv+6m7MRc4qIgkVHwK
=4beA
-----END PGP SIGNATURE-----

--=-Hmgr7MoU8XHjGL/j+NTg--
