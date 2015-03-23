From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [PATCH net-next v6 6/7] ixgbevf: Add RSS Key query code
Date: Mon, 23 Mar 2015 03:31:37 -0700
Message-ID: <1427106697.2577.163.camel@jtkirshe-mobl>
References: <1427050887-19412-1-git-send-email-vladz@cloudius-systems.com>
	 <1427050887-19412-7-git-send-email-vladz@cloudius-systems.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-CCUdGe09OHgcp1FLz6AK"
Cc: netdev@vger.kernel.org, avi@cloudius-systems.com,
	gleb@cloudius-systems.com
To: Vlad Zolotarov <vladz@cloudius-systems.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:22988 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752331AbbCWKbr (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 23 Mar 2015 06:31:47 -0400
In-Reply-To: <1427050887-19412-7-git-send-email-vladz@cloudius-systems.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-CCUdGe09OHgcp1FLz6AK
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Sun, 2015-03-22 at 21:01 +0200, Vlad Zolotarov wrote:
> Add the ixgbevf_get_rss_key() function that queries the PF for an RSS
> Random Key
> using a new VF-PF channel IXGBE_VF_GET_RSS_KEY command.
>=20
> Signed-off-by: Vlad Zolotarov <vladz@cloudius-systems.com>
> ---
> New in v6:
>    - Return a proper return code when an operation is blocked by PF.
>=20
> New in v2:
>    - Added a more detailed patch description.
>=20
> New in v1 (compared to RFC):
>    - Use "if-else" statement instead of a "switch-case" for a single
> option case
>      (in ixgbevf_get_rss_key()).
> ---
>  drivers/net/ethernet/intel/ixgbevf/mbx.h |  2 ++
>  drivers/net/ethernet/intel/ixgbevf/vf.c  | 48
> ++++++++++++++++++++++++++++++++
>  drivers/net/ethernet/intel/ixgbevf/vf.h  |  1 +
>  3 files changed, 51 insertions(+)

Thanks Vlad, I have applied your patch to my next-queue tree
--=20
git://git.kernel.org/pub/scm/linux/kernel/git/jkirsher/next-queue.git
dev-queue

--=-CCUdGe09OHgcp1FLz6AK
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAABCgAGBQJVD+uJAAoJEOVv75VaS+3O+oQQAIXW0Z+1HOh43u4ia8aEzR2y
r3k45OPanM4sNe+uyt69P1GzRYL1pM7LH0eofeLCHX9enmyvU/+aPHBc6iFEBM78
PJe0EGYWmIh1Y92FriAY/lvkVlqG+ld8/GfVjC5X1YuQwvUApTljqppAHVgN6nuD
Domg3uzOGb3tagKo5SOqCagRn72LgXWgS3kBk06DX23gNXfCiAhwWybWXb2SoMyF
ltgYN5kYgalCVekHC69f2mhrINXiGsohE4ehjlWgipbgXtusCVwuoQN7yDJ7vIXh
D2yKo354xpsNFPzWP3tMRCTfs8iThm3NiFTOKy8V7J1nbOUAudeT4LCrhOy0RLGl
cZxcr8bPWO8WsmYgeHqV8TcO2I0VVORxgv8oDOB3/2QfuW94AoG0Yc7jupE1SPWw
u5icKoXJA5gVW5RDQ9NvXSTnA8Jng+RWQCurkuHfQvbffgYBf5gXTOut6rDTRAEB
ygUPGKDggsxlxV1ZvePM+FZ382PmSHqt/YQQDGktoGQmaWfcfsfFsa001gebWcc8
q5HWx0TYOeGb/GW2hj/2k+X94zxnpD6bCqFyLND509hP103cGvStWmChlVPM78N1
T/ZfvttDXdUT4rkosv10fq3SDWqHSf5vJvdP3AqmAv0hJNIGsMahEmOMO3oMBStC
5NveRyu997nXlJbNgGTc
=4BNH
-----END PGP SIGNATURE-----

--=-CCUdGe09OHgcp1FLz6AK--
