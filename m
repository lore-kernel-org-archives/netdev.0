From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [PATCH net-next v6 5/7] ixgbe: Add GET_RSS_KEY command to VF-PF
 channel commands set
Date: Mon, 23 Mar 2015 03:31:24 -0700
Message-ID: <1427106684.2577.162.camel@jtkirshe-mobl>
References: <1427050887-19412-1-git-send-email-vladz@cloudius-systems.com>
	 <1427050887-19412-6-git-send-email-vladz@cloudius-systems.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-CIarF85xVCre/i2EKbSE"
Cc: netdev@vger.kernel.org, avi@cloudius-systems.com,
	gleb@cloudius-systems.com
To: Vlad Zolotarov <vladz@cloudius-systems.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([134.134.136.65]:58218 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752141AbbCWKbZ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 23 Mar 2015 06:31:25 -0400
In-Reply-To: <1427050887-19412-6-git-send-email-vladz@cloudius-systems.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-CIarF85xVCre/i2EKbSE
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Sun, 2015-03-22 at 21:01 +0200, Vlad Zolotarov wrote:
> For 82599 and x540 VFs and PF share the same RSS Key. Therefore we
> will return
> the same RSS key for all VFs.
>=20
> x550 on the other hand has a separate RSS Key for every pool.
>=20
> Signed-off-by: Vlad Zolotarov <vladz@cloudius-systems.com>
> ---
> New in v5:
>    - Use a newly added netdev op to allow/prevent the RSS Hash Key
> querying on a per-VF
>      basis.
>=20
> New in v3:
>    - Added a support for x550 devices.
>=20
> New in v1 (compared to RFC):
>    - Use "if-else" statement instead of a "switch-case" for a single
> option case
>      (in ixgbe_get_vf_rss_key()).
> ---
>  drivers/net/ethernet/intel/ixgbe/ixgbe_mbx.h   |  2 ++
>  drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.c | 27
> ++++++++++++++++++++++++++
>  2 files changed, 29 insertions(+)

Thanks Vlad, I have applied your patch to my next-queue tree
--=20
git://git.kernel.org/pub/scm/linux/kernel/git/jkirsher/next-queue.git
dev-queue

--=-CIarF85xVCre/i2EKbSE
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAABCgAGBQJVD+t8AAoJEOVv75VaS+3OMgUP/ibAvQcTagKo77ag7KIpX4eT
OUlm3zW+ggT0BTgxepNbDgBnglHIW0JeQdFxgrpEOpnh6QcqBqXT9NaICq9ZYORs
BHdLabc5Uw5xRNfEff2dlqx7S0IZClvYLU+TNn8Za00esypHtqP+KEbobHS5NHtT
6kA1WqvTS1lHdspIKwyzwKqSHfvazFx1jdH0kNa4u8QfH7gVN2Juvwt3FKnxm1hB
TpRFnamflhSpsOUhUDjRY76Dzh50N6NvGOpiqzso11fh5NMeNYuTQPNaQiHyLP5f
VUv4YJpMgmDYkt7Cd2ZRvfoUcrzoUMPJr61s8kBhPEatw9nho56MOERvRJnCGezf
Szxw0jUohJrtUN+yWHbdMlugLkJwNfY+v9urJe9RDs4Y4QvEcCroxno+GRCF8CzK
bl9MuwkcYKsjYx3CyWAA9Cd8yUV3hSBEZfIqTGtXtzkTflPgrTCrmhAgZ9V6BHNT
oM+0T3iAXWfpy/aLGFsS0WkHWXrFMIgQruuQtdwDONt2mZMccJ+JArDtNGr0iBrU
cdRUWtkDr/j2kU0TYrWIYDqmC+f3DYXUusTxVximguUuVEtizI3Tz4v9wGIJexXI
dTtmNKqGoDlnB2c+1V9e5rz9XjfamfxG5s1ZtslUj55OWpzw+BYDqONINGhTuglL
rqwWBpCaAdT9bNt7LPPI
=9ifI
-----END PGP SIGNATURE-----

--=-CIarF85xVCre/i2EKbSE--
