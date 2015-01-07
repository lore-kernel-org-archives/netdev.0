From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [PATCH net-next v5 0/7]: ixgbevf: Allow querying VFs RSS
 indirection table and key
Date: Wed, 07 Jan 2015 12:03:45 -0800
Message-ID: <1420661025.2491.73.camel@jtkirshe-mobl>
References: <1420658802-18061-1-git-send-email-vladz@cloudius-systems.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-/NNSYGeSX5J0t1BNxtH3"
Cc: netdev@vger.kernel.org, gleb@cloudius-systems.com,
	avi@cloudius-systems.com
To: Vlad Zolotarov <vladz@cloudius-systems.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([134.134.136.65]:21853 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751528AbbAGUD4 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 7 Jan 2015 15:03:56 -0500
In-Reply-To: <1420658802-18061-1-git-send-email-vladz@cloudius-systems.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-/NNSYGeSX5J0t1BNxtH3
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Wed, 2015-01-07 at 21:26 +0200, Vlad Zolotarov wrote:
> Add the ethtool ops to VF driver to allow querying the RSS indirection
> table
> and RSS Random Key.
>=20
> On some devices VFs share the RSS Redirection Table and Hash Key with
> a PF and letting
> the VF query this information may introduce some security risks.
> Therefore we disable this
> feature by default for such devices (e.g. 82599) and allow it for
> those where there isn't any
> possible risk (e.g. on x550). The new netdev op is going to allow a
> system administrator to
> change the default behaviour with "ip link set" command.
>=20
>  - netdev: Add a new netdev op to allow/block VF from querying RSS
> Indirection Table and
>    RSS Hash Key.
>  - PF driver: Add new VF-PF channel commands.
>  - VF driver: Utilize these new commands and add the corresponding
>               ethtool callbacks.
>=20
> New in v5:
>    - Added a new netdev op to allow/block VF from querying RSS
> Indirection Table and
>      RSS Hash Key.
>    - Let VF query the RSS info only if VF is allowed to.
>=20
> New in v4:
>    - Forgot to run checkpatch on v3 and there were a few styling
> things to fix. ;)
>=20
> New in v3:
>    - Added a missing support for x550 devices.
>    - Mask the indirection table values according to PSRTYPE[n].RQPL.
>    - Minimized the number of added VF-PF commands.
>=20
> New in v2:
>    - Added a detailed description to patches 4 and 5.
>=20
> New in v1 (compared to RFC):
>    - Use "if-else" statement instead of a "switch-case" for a single
> option case.
>      More specifically: in cases where the newly added API version is
> the only one
>      allowed. We may consider using a "switch-case" back again when
> the list of
>      allowed API versions in these specific places grows up.
>=20
> Vlad Zolotarov (7):
>   if_link: Add an additional parameter to ifla_vf_info for RSS
> querying
>   ixgbe: Add a new netdev op to allow/prevent a VF from querying an
> RSS
>     info
>   ixgbe: Add a RETA query command to VF-PF channel API
>   ixgbevf: Add a RETA query code
>   ixgbe: Add GET_RSS_KEY command to VF-PF channel commands set
>   ixgbevf: Add RSS Key query code
>   ixgbevf: Add the appropriate ethtool ops to query RSS indirection
>     table and key
>=20
>  drivers/net/ethernet/intel/ixgbe/ixgbe.h          |   1 +
>  drivers/net/ethernet/intel/ixgbe/ixgbe_main.c     |   7 ++
>  drivers/net/ethernet/intel/ixgbe/ixgbe_mbx.h      |  10 ++
>  drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.c    | 119
> +++++++++++++++++++
>  drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.h    |   2 +
>  drivers/net/ethernet/intel/ixgbevf/ethtool.c      |  42 +++++++
>  drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c |   4 +-
>  drivers/net/ethernet/intel/ixgbevf/mbx.h          |  10 ++
>  drivers/net/ethernet/intel/ixgbevf/vf.c           | 132
> ++++++++++++++++++++++
>  drivers/net/ethernet/intel/ixgbevf/vf.h           |   2 +
>  include/linux/if_link.h                           |   1 +
>  include/linux/netdevice.h                         |   8 ++
>  include/uapi/linux/if_link.h                      |   8 ++
>  net/core/rtnetlink.c                              |  33 +++++-
>  14 files changed, 372 insertions(+), 7 deletions(-)

Thanks Vlad, I will add your patches to my queue.

--=-/NNSYGeSX5J0t1BNxtH3
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAABCgAGBQJUrZEhAAoJEOVv75VaS+3OkVcQAJFEytNHUNVje2spcCr3ci7A
oNnBR+cHgJbEa/z+mjMcW710zIAxSMa2KQxavI/Xmt3/rMp2QcFjSuEdQwz15Wo8
qyn4KdmjILGVXxAchJBxvdBH8ZxDRPqSXJspjB4y1yW7onGdv6E/Zpi5ZBfDDkP3
l2g3FmQsnFXUuxgbNTU+Ba9WuH5EaB8Hj1NeWfN6hsXZKMYdl+fSxpcyypJriMmg
3JZ2KMSv0PFBu5bRmwTgCf9VJ+rp8L8nIkRdtkOZx0+U/htZrV31svN9VzsW5sPW
M9Md7iNNhbQVwku7y0gEMdoc8U1cTa3hRhYw0gsUa6zv+eLd67QtRh0OKoZ1pv1W
1KBcOBFafyQ4/bNjU1CAUSPpLiScX/IF+17tUZxiQp/wlrcd/vW2QM34oWkRYlw+
tMEcf2melRWNhAHcEUwrh2DGqwMbR+YovBTRLa4Ex44Yv7UCV4YGipzdlvw6fYjI
3tD9eB1LuD4jTWXVKg79TQz3GxYIUtQQLYK1FJewQdP/SgcWKtvVJYCfDSnq7bjX
9Qm2nDLfI2Z6hPpxSlKlOZph0jMOoncl5CumLrXnxvLJ0Mj90mcmaYXxhVvTTXLf
tr6wSwbrOig2LUMBgyuytGKC9JncuP465H5h5KkWTLvT12xY/l0ZsjOawnYMzlWP
Wyul1K2pcWtFFknK0tDb
=cyEA
-----END PGP SIGNATURE-----

--=-/NNSYGeSX5J0t1BNxtH3--
