From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [PATCH net-next v2 1/2] ixgbe: Refactor the RSS configuration
 code.
Date: Thu, 26 Mar 2015 21:15:12 -0700
Message-ID: <1427429712.2497.42.camel@jtkirshe-mobl>
References: <1427409886-20261-1-git-send-email-vladz@cloudius-systems.com>
	 <1427409886-20261-2-git-send-email-vladz@cloudius-systems.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-aG0Ob5zgSQ+LjlZz/RO/"
Cc: netdev@vger.kernel.org, intel-wired-lan@lists.osuosl.org,
	avi@cloudius-systems.com, gleb@cloudius-systems.com
To: Vlad Zolotarov <vladz@cloudius-systems.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:34551 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750864AbbC0EPP (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 27 Mar 2015 00:15:15 -0400
In-Reply-To: <1427409886-20261-2-git-send-email-vladz@cloudius-systems.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-aG0Ob5zgSQ+LjlZz/RO/
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Fri, 2015-03-27 at 00:44 +0200, Vlad Zolotarov wrote:
> This patch is a preparation for enablement of ethtool RSS indirection
> table
> and hash key querying. We don't want to read registers every time the
> RSS info
> is queried. Therefore we will store its current content in the
> arrays in the adapter struct and will read it from there (instead of
> from
> registers) when requested.
>=20
> Will change the code that writes the indirection table and hash key
> into the HW registers
> to take its content from these arrays. This will also simplify the
> indirection
> table updating ethtool callback implementation in the future.
>=20
> Signed-off-by: Vlad Zolotarov <vladz@cloudius-systems.com>
> ---
> New in v2:
>    - Some styling fixes.
>    - Moved macros definitions from ixgbe_type.h to ixgbe.h.
> ---
>  drivers/net/ethernet/intel/ixgbe/ixgbe.h      |   9 ++
>  drivers/net/ethernet/intel/ixgbe/ixgbe_main.c | 142
> ++++++++++++++++++--------
>  2 files changed, 108 insertions(+), 43 deletions(-)

I have added this to my queue.
--=20
git://git.kernel.org/pub/scm/linux/kernel/git/jkirsher/next-queue.git
dev-queue

--=-aG0Ob5zgSQ+LjlZz/RO/
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAABCgAGBQJVFNlQAAoJEOVv75VaS+3OiKAP/istpFqvN2t4Ll9Dw7en/YFZ
MOpPUJnav4urVdiEz/825Y2cWEFmQbwQemGrlJ+oeBgpCnYtri9mgMdS00aUA+P3
K/b0wg9J4x77HOfv/OvZaPbsimGL3aemK2ZFrRmpjsJaEEuaFZZgyELPIMWvMpcB
OFCC31gP5Mn9vhjGk3YbIMqdsKwkQlPtFX7/DQ1HuTNmyJbKztqyIlyZEjOb4hyk
/al+2HsP4JiSj3bZanij6N0CmARfL/LhVqqtCEUNjQYQ/0mX7ySh760lEmpiilrf
SXh2AgUoVhuV0pnQbVOMFGHdyJkla8vx7LQoX66SrCWdAbq3utiDCMMPTbswSmFq
7jCjVIYPytCf0dRiU2oXKpzVNrSnAljaA8rQRqBhmqowEcwItrWVwXpl2e6erxdu
ZcTcJtjwQVL8qqB+U5aLPULc6z0tBdpT1oX0E/PDPxkDkakyyPLx98PTPF1h5+uF
e1mpq7U5XoTyZ7z4twjR9eLjUXmZLD30YZfzBCdNsTAOBZq5XJrQNtmr3KvjVFDJ
qq3xBe6860mVaDmV72sdxYTZ7EdM54/KQPN7EOZVluGuo734KI0XFzG05WCIRB0m
hQ9bxAZoi17Ybs9G+ix+dUDuKxMeVSfCpNOVsncPzIdTl4EovQXa12SBgLKLUvyQ
/PzoqUaHQAldU1kRR8Xd
=dKYM
-----END PGP SIGNATURE-----

--=-aG0Ob5zgSQ+LjlZz/RO/--
