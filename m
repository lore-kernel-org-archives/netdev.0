From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [PATCH net-next v6 3/7] ixgbe: Add a RETA query command to
 VF-PF channel API
Date: Mon, 23 Mar 2015 03:30:50 -0700
Message-ID: <1427106650.2577.160.camel@jtkirshe-mobl>
References: <1427050887-19412-1-git-send-email-vladz@cloudius-systems.com>
	 <1427050887-19412-4-git-send-email-vladz@cloudius-systems.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-7ODZ0th3VaHW+XqesraX"
Cc: netdev@vger.kernel.org, avi@cloudius-systems.com,
	gleb@cloudius-systems.com
To: Vlad Zolotarov <vladz@cloudius-systems.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([192.55.52.115]:44211 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752097AbbCWKav (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 23 Mar 2015 06:30:51 -0400
In-Reply-To: <1427050887-19412-4-git-send-email-vladz@cloudius-systems.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-7ODZ0th3VaHW+XqesraX
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Sun, 2015-03-22 at 21:01 +0200, Vlad Zolotarov wrote:
> 82599 and x540 VFs and PF share the same RSS redirection table (RETA).
> Therefore we
> just return it for all VFs. x550 on the other hand provides a separate
> redirection
> table for each VF (there is a per-pool RETA table).
>=20
> For 82599 and x540 RETA table is an array of 32 registers (128 bytes)
> and the maximum number of
> registers that may be delivered in a single VF-PF channel command is
> 15. Therefore
> we will deliver the whole table in 3 steps: 12, 12 and 8 registers in
> each
> step correspondingly.
>=20
> For x550 VFs RETA is a 64 byte array, so we may deliver it in two
> steps: 12 and 4 registers
> correspondingly.
>=20
> Thus this patch does the following:
>=20
>   - Adds a new API version (to specify a new commands set).
>   - Adds the IXGBE_VF_GET_RETA command to the VF-PF commands set.
>=20
> Signed-off-by: Vlad Zolotarov <vladz@cloudius-systems.com>
> ---
> New in v5:
>    - Use the newly added netdev op to allow/prevent the RETA query on
> a per-VF basis.
>=20
> New in v4:
>    - Deleted an empty line in ixgbe_get_vf_reta() switch-case.
>=20
> New in v3:
>    - Pass the number of dwords and offset in RETA in the
> IXGBE_VF_GET_RETA request message.
>      This allows to reduce the added command set to a single command.
>    - Added a support for all devices supported by the ixgbe driver
> that have
>      SR-IOV functions support: 82599, x540 and x550. The original code
> supported
>      only 82599 and x540.
>    - Added the masking of the RETA entries according to the
> PSRTYPE[n].RQPL
>      value.
>=20
> New in v1 (compared to RFC):
>    - Use "if-else" statement instead of a "switch-case" for a single
> option case
>      (in ixgbe_get_vf_reta()).
> ---
>  drivers/net/ethernet/intel/ixgbe/ixgbe_mbx.h   |  8 ++++
>  drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.c | 65
> ++++++++++++++++++++++++++
>  2 files changed, 73 insertions(+)

Thanks Vlad, I have applied your patch to my next-queue tree
--=20
git://git.kernel.org/pub/scm/linux/kernel/git/jkirsher/next-queue.git
dev-queue

--=-7ODZ0th3VaHW+XqesraX
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAABCgAGBQJVD+taAAoJEOVv75VaS+3OCxMP/1jnzJQktGx5351bNFS8fxbz
The7e+3V8JfX6//5KxwKmaaRMSmCX14LjOKIhOu1kOD3PAuhSiC6KSqJPWB/aQQO
Ilk2Tlgik8NywC9U40AT5aIwdZK3TetkKnJF4wnv0pCXi3JZazUgNSZCJ7L6esJX
NathxSH7RuJn4h+O+BiIGfQJhwf7a+Wla4Pd1q/5C1GimD8uwl0t+BVXCVWfqEoF
PC4sG861XVn1iu3QpHyavwjKsiw4Pr0pW9oy0RoNLQZcR0raUgMexQLHyq+rrVNu
tTR9KB9gQ7KnD4fqeE64WY9Rwov/Yo6fLDQ3PAVgoQaVwPiv2YmLfb/eqZZYTkq3
kxx+DowZh8BqYiK2Y+s6iIS0bTf/8R4DyqrT0X+w8xiEjjTgJMGvghCxTna1XvMr
ExR+EeV26yY3aER7lkIGNJdm0v21f8481DWgv+4dKZYhtEW9H8CpcX/bEIj/QoDm
5qjb4LiW2L5v2798CB4e8/r9nwfOHvXGVRFT4fD+3e6Zi0RWCJuRHbhZ6Jk2/+tZ
T9oJ3IMvBwWY7oxPeK1Y1vToXUgOJ3hvJedaVSmkN3850A09wPMmcG/a8p+G9LKJ
LZTA8dX1mlDqybCI3wLh6EAEaUbcoPNh08SLQOwkSrZMi+8/gbHwu5AB+BOHAsX0
mPKJjKRv2+Ylt9F2O6fk
=Svhg
-----END PGP SIGNATURE-----

--=-7ODZ0th3VaHW+XqesraX--
