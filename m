From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [PATCH v3 1/3] ixgbe, ixgbevf: Add new mbox API to enable MC
 promiscuous mode
Date: Wed, 08 Apr 2015 13:43:21 -0700
Message-ID: <1428525801.2579.6.camel@jtkirshe-mobl>
References: <7F861DC0615E0C47A872E6F3C5FCDDBD05E7CD29@BPXM14GP.gisp.nec.co.jp>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-6NEZ30OKwBlh4vnNNxTe"
Cc: Or Gerlitz <gerlitz.or@gmail.com>,
	"vyasevic@redhat.com" <vyasevic@redhat.com>,
	"e1000-devel@lists.sourceforge.net"
	<e1000-devel@lists.sourceforge.net>,
	"Choi, Sy Jong" <sy.jong.choi@intel.com>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	David Laight <David.Laight@aculab.com>,
	Hayato Momma <h-momma@ce.jp.nec.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Edward Cree <ecree@solarflare.com>,
	=?ISO-8859-1?Q?Bj=F8rn?= Mork <bjorn@mork.no>
To: Hiroshi Shimamoto <h-shimamoto@ct.jp.nec.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([192.55.52.115]:46909 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753439AbbDHUnf (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 8 Apr 2015 16:43:35 -0400
In-Reply-To: <7F861DC0615E0C47A872E6F3C5FCDDBD05E7CD29@BPXM14GP.gisp.nec.co.jp>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-6NEZ30OKwBlh4vnNNxTe
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Wed, 2015-04-08 at 05:36 +0000, Hiroshi Shimamoto wrote:
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
>=20
> This adds new mbox API, but doesn't change the version because
> v1.3 was newly added in the current dev-queue.
> Is that okay, or shall I increment the version?
>=20
>  drivers/net/ethernet/intel/ixgbe/ixgbe.h          |  1 +
>  drivers/net/ethernet/intel/ixgbe/ixgbe_mbx.h      |  2 +
>  drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.c    | 76
> +++++++++++++++++++++++
>  drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c |  3 +
>  drivers/net/ethernet/intel/ixgbevf/mbx.h          |  2 +
>  drivers/net/ethernet/intel/ixgbevf/vf.c           | 27 +++++++-
>  drivers/net/ethernet/intel/ixgbevf/vf.h           |  1 +
>  7 files changed, 111 insertions(+), 1 deletion(-)

I will add this to my queue, thanks Hiroshi.

--=-6NEZ30OKwBlh4vnNNxTe
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAABCgAGBQJVJZLpAAoJEOVv75VaS+3OxPkP/0XH+MXpLkjNJw4yjXjU46GN
Yvj2kCZk/oPOGK8a5wvjGtvQ3MtOYUqkT+JwJLAMELAi6xh0jhjE4gFXluSHgkdS
LqFH+SmpfeR9rb4a8EMIFb+ixV2Qd+ZVR1+KStxta4qpc80wnMtaWK5hAovmh5iA
2qRDqxHa2NN+NmAFw7b7+7Jyy5lnuEIA63vOkXo/UXxBVPkNSs3FCGr52jE10OUE
ZmsllKOa0e3HL8jV6pqSVWlQtL3+/6KTMfj+opbbfqAxQkGq5nW2XupGvavTrx6N
7AdLAbTJmSE0t6AzhMWlsX4EO+g7lGJH+LleJHCe7dSqMoTVlVG2MgWRo15trXf4
THXb3qCeim5PZMg+796jslAo1O5WmteeNj9nCDxvMQhlfQkjkW6zGaU5esMnzNiY
7U/rXwfIAQHElp754hg1n+eE7GIQMbbY6C8z2JD0/i8+TootZGBpmmpR5oLy4AKY
TSffytZny2Dh1Rp0KyCy1JJ6g39mRPGgxzUBcK/Cl4Jd7v/n+nKnMrPaSSlV3y+T
G1IM+hd6eXO3QZ3iq9Z04F2SKqE8oAhxCJua+1yD0OtFQCeGPJelgqWvSpxoQW/n
syS+BrVlZUra9S0o/XexcaYPd+mrBePmPvFkciqh6/Y2X3gQdSvTNljIeUdkJ6xe
GbsZvIrvrizUqbLksJcM
=MCBJ
-----END PGP SIGNATURE-----

--=-6NEZ30OKwBlh4vnNNxTe--
