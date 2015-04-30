From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [PATCH v2 0/3] RSS fix for ixgbe/ixgbevf
Date: Thu, 30 Apr 2015 05:59:41 -0700
Message-ID: <1430398781.2669.110.camel@jtkirshe-mobl>
References: <1430276261-29821-1-git-send-email-fan.du@intel.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-XrJx4BLspoka1S0Lc9Hg"
Cc: alexander.h.duyck@redhat.com, emil.s.tantilov@intel.com,
	intel-wired-lan@lists.osuosl.org, netdev@vger.kernel.org
To: Fan Du <fan.du@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:27786 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751639AbbD3M7m (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 30 Apr 2015 08:59:42 -0400
In-Reply-To: <1430276261-29821-1-git-send-email-fan.du@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-XrJx4BLspoka1S0Lc9Hg
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Wed, 2015-04-29 at 10:57 +0800, Fan Du wrote:
> This patchset provides RSS hash value for upper stack by indicating
> whether it's a L3 or L4 hash. Thus other component of network
> stack could utilize this hash value provided by NIC without caculating
> by themselves.
>=20
> Test:
> * Simple iperf test using ixgbe for 82599ES
> * Build test only for ixgbevf
> * make C=3D1 CF=3D-D__CHECK_ENDIAN__, no warnings introduced by this patc=
hset
>=20
> Changelog:
> v2:
>   - Add patch3 to make all hash value from RSS part.
> v1:
>   - Code style issue suggeted by Tantilov, Emil S.
>   - Initial version
>=20
> Fan Du (3):
>   ixgbe: Specify rx hash type wrt rx desc RSS type
>   ixgbevf: Set rx hash type for ingress packets
>   ixgbe: Don't report flow director filter's status
>=20
>  drivers/net/ethernet/intel/ixgbe/ixgbe_82599.c    |    2 -
>  drivers/net/ethernet/intel/ixgbe/ixgbe_main.c     |   25 +++++++++++++++=
+---
>  drivers/net/ethernet/intel/ixgbevf/defines.h      |   12 +++++++++
>  drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c |   27 +++++++++++++++=
++++++
>  4 files changed, 60 insertions(+), 6 deletions(-)
>=20

Thanks Fan, I have added your series to my queue for further review and
testing.

--=-XrJx4BLspoka1S0Lc9Hg
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAABCgAGBQJVQic9AAoJEOVv75VaS+3O9g0P/3CjBBlDP6Lo561tcTiUWLGZ
RynPv+jhNWrcYDoN7l8B2evbZTT9EeMFgEGjD455yXDTQ+XMWit691TQv9pFp+Ed
wEX7PlWZpKWylJHBObeqYOMZ8QVsroEM7ANJbeOH6AU0zaShenIwCks+FATDsYzX
4zX8Atbz1wYnM4P4+if7eY0vwYSXQP6zIb066EkfCl/slETr7b0veevanzC6HH8U
EnFoP1z4JOz82Lnp2u1vLZPzLyXZ2IT8SObKhZM97HMMu/XjrdsTqJeVnorEPauN
OL9FAuG76clUdqC1QM0dJ59KtC2yhL0GUsS/TT7+gNb/ONKClvFPhXLMB8NgKPb/
3MkzR9gaSZqkEEkXqkx90YozDZynTbW+AVZN+YHg9Ss8RY+di2BeFRHAKFnULOS0
7jZLwcY0AogXeO9N2HZf47vl/Z0lLXpYk++tAq2jHLjXc05sdh/hxEY/rTdndpFu
C8GvdeQfXgdVb7r/K+twgiID35v8ZGUX2mXcn1sTAv4J2mUKhn1QGoeBl32lLYfD
LOPS356EsoB3urfNdArJqN3bcodY8ijBguiW3NzxC366UcbmHDwiMOBwMEoFYnmR
LttfY0p0WUQnHhK4PtPG5a9gncdyjX3FUi6OQijGPbL62hMSIMENXC6WV/3Mn5bn
b+5btDYji9y3ne0oyCx2
=Q3TP
-----END PGP SIGNATURE-----

--=-XrJx4BLspoka1S0Lc9Hg--
