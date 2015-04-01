From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [PATCH net-next v11 3/7] ixgbe: Add a RETA query command to
 VF-PF channel API
Date: Wed, 01 Apr 2015 01:33:01 -0700
Message-ID: <1427877181.2662.21.camel@jtkirshe-mobl>
References: <1427876694-19821-1-git-send-email-vladz@cloudius-systems.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-Zd5+fIzFu5b65KhhmxeN"
Cc: netdev@vger.kernel.org, intel-wired-lan@lists.osuosl.org,
	avi@cloudius-systems.com, gleb@cloudius-systems.com
To: Vlad Zolotarov <vladz@cloudius-systems.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:38309 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750701AbbDAIdC (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 1 Apr 2015 04:33:02 -0400
In-Reply-To: <1427876694-19821-1-git-send-email-vladz@cloudius-systems.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-Zd5+fIzFu5b65KhhmxeN
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Wed, 2015-04-01 at 11:24 +0300, Vlad Zolotarov wrote:
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
> 15. On the other hand VFs
> of these devices can be configured to have up to 4 RSS queues.
> Therefore we will "compress"
> the RETA by transfering only 2 bits per entry and thereby it will take
> only 8 registers (DWORDS)
> to transfer the whole VF RETA.
>=20
> Thus this patch does the following:
>=20
>   - Adds a new API version (to specify a new commands set).
>   - Adds the IXGBE_VF_GET_RETA command to the VF-PF commands set.
>=20
> Signed-off-by: Vlad Zolotarov <vladz@cloudius-systems.com>
> ---
> New in v11:
>    - Updated the patch description.
>=20
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

--=-Zd5+fIzFu5b65KhhmxeN
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAABCgAGBQJVG609AAoJEOVv75VaS+3OkPQP/jodl7Hx29ZOzlKCP2vCw653
qddJZU1FQmytRrOGhyv7DVr/bCvUgoVO/ArhmH/7Y/Se76P0fI6IAzl12tFQ4uj4
Q8CkHVLdlSUk092pWasnSOnAT0VqoIetIXkPQhDR5qtgvLg6tZeJjKBd5cSBEm+9
11qHajaVWIKNRFCTPE+9QzM08S92N7M2xUeMZxA9pdI4VvCbhxGM5sjTyonKoD2t
dMzZve2qKjBThIBmSenDFX3EySYPbJhW9WCjkvV6y43tromoqeg3oMiEZO+ESDOT
w6b6igLCFt5riSBvZ2y8KUOE0t2gVjYkb5kxiDrtOBDlfWPDDnAHJhyo9gElxTFL
GQbUd0hL3wMElGkDdmNga+5sHTffuT811qF25W8TzN1T1TLDiEaTt0ygca+ubb9M
7oNRcOfsna4CmyNAhphMlFLOb2LyO/1JkHCDxorH4ERO87EoNbTSqeBXC+WkdUx/
DRa4bzQKQkdRJ8aCsHE9yMwP0L60J3jn0yItiuCJaQ5fU0AJjfLFGEo6wrYuLyLt
2Oo1DbYSTqvKRvjhcjrBpTtickYylZ0eWYOepemAl59LThCkYqni0s3Oned3fCCV
br62n/U6gHDp73vsz1tUmnBcTv27tRzF1juvOIIsArW0qqk/0fEFU5HDPi9RtZY2
UKYP+oV5GZLBapmuy81Y
=7RkY
-----END PGP SIGNATURE-----

--=-Zd5+fIzFu5b65KhhmxeN--
