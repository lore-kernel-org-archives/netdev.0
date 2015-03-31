From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [PATCH net-next v10 3/7] ixgbe: Add a RETA query command to
 VF-PF channel API
Date: Tue, 31 Mar 2015 00:35:27 -0700
Message-ID: <1427787327.2497.111.camel@jtkirshe-mobl>
References: <1427740529-9605-1-git-send-email-vladz@cloudius-systems.com>
	 <1427740529-9605-4-git-send-email-vladz@cloudius-systems.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-dGnw948mSHBNmHwNXWe0"
Cc: netdev@vger.kernel.org, intel-wired-lan@lists.osuosl.org,
	avi@cloudius-systems.com, gleb@cloudius-systems.com
To: Vlad Zolotarov <vladz@cloudius-systems.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([134.134.136.65]:23983 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753166AbbCaHfh (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 31 Mar 2015 03:35:37 -0400
In-Reply-To: <1427740529-9605-4-git-send-email-vladz@cloudius-systems.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-dGnw948mSHBNmHwNXWe0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Mon, 2015-03-30 at 21:35 +0300, Vlad Zolotarov wrote:
> Add this new command for 82599 and x540 devices only. Support for
> other devices
> will be added later.
>=20
> 82599 and x540 VFs and PF share the same RSS redirection table (RETA).
> Therefore we
> just return it for all VFs.
>=20
> For 82599 and x540 RETA table is an array of 32 registers (128 bytes)
> and the maximum number of
> registers that may be delivered in a single VF-PF channel command is
> 15. Therefore
> we will deliver the whole table in 3 steps: 12, 12 and 8 registers in
> each
> step correspondingly.
>=20
> Thus this patch does the following:
>=20
>   - Adds a new API version (to specify a new commands set).
>   - Adds the IXGBE_VF_GET_RETA command to the VF-PF commands set.
>=20
> Signed-off-by: Vlad Zolotarov <vladz@cloudius-systems.com>
> ---
> New in v10:
>    - Drop the PRSTYPE reading since it's VF that finally modifies it
> (via VFPSRTYPE)
>      and we will add the proper masking at the VF driver level.
>    - Return more self-explaining values.
>=20
> New in v9:
>    - Reduce the support to 82599 and x540 devices only.
>    - Improvements in query RETA VF-PF command implementation:
>       - Use the cached RETA contents.
>       - Compress the mailbox message.
>=20
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
>  drivers/net/ethernet/intel/ixgbe/ixgbe_mbx.h   |  4 +++
>  drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.c | 35
> ++++++++++++++++++++++++++
>  2 files changed, 39 insertions(+)

Thanks Vlad, applied to my queue.
--=20
git://git.kernel.org/pub/scm/linux/kernel/git/jkirsher/next-queue.git
dev-queue

--=-dGnw948mSHBNmHwNXWe0
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAABCgAGBQJVGk4/AAoJEOVv75VaS+3OFU8P/jznPS4t/oQgJvtxB4qqqzXf
BhTav/hzGUXoXWcZnoTETLXXaMJXP0bz8CRGuUvjwEPTAQ3rGV+ddq58NIPVfuy0
eK75uH+pKqHDQBYXUWqxHeizH3vsRQ2GRUUzvsww0bAAD7/oxje3SjI8cYYGNgPw
xCNcUN/FRKgirsdxeKcjzgLUqvZaXzVP7nbmUtZO9C4KvcPWzqT+/YayrmaWKYH2
I8H2vKnhGjSxvc74R5pLi0LRHUuKPOiPXB72PALFTc14hIoSrhv6TUdvW7llmB18
WZuGCbuFpSTxvAHgQjRkryg+5Pju6PkWj1whca9rGNrQd+pCRe798q82kfmLMLIB
qtQUQQHSOUg8QCaxyC45lwyZtjlIUNz6doNnsseVvH+6rBXee2By39PhbZuc9N7W
d/WCOQD912didMocVCreEACZD8sKaSmCZOvW3KZ57WdSiJiDAFq8wIbMKtLPs9xR
6BfYd93yxUlIDipCxx9XMgAuK0dYr2vGBQ/r/Ue4TZJSMBAc7m8GxE9NRjAS2pCC
0DGtK8p9pjFZwHR9D+oQRpV+lPkZkmVD67iUw6MyfzvMCLZPJRcPHX8CwDJDJZvN
EppkBWRN5ML7zXL2+w8p7V8S9a0cX03iOS8zXDcd5nIpiPUZFr+LP4ljtUnlbqwG
8w/YLzQiTuTUFegKX2xk
=ga58
-----END PGP SIGNATURE-----

--=-dGnw948mSHBNmHwNXWe0--
