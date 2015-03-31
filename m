From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [PATCH net-next v10 5/7] ixgbe: Add GET_RSS_KEY command to
 VF-PF channel commands set
Date: Tue, 31 Mar 2015 00:35:59 -0700
Message-ID: <1427787359.2497.113.camel@jtkirshe-mobl>
References: <1427740529-9605-1-git-send-email-vladz@cloudius-systems.com>
	 <1427740529-9605-6-git-send-email-vladz@cloudius-systems.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-rw04sEnCy42QMkbrJ2cE"
Cc: netdev@vger.kernel.org, intel-wired-lan@lists.osuosl.org,
	avi@cloudius-systems.com, gleb@cloudius-systems.com
To: Vlad Zolotarov <vladz@cloudius-systems.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:11723 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751998AbbCaHgA (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 31 Mar 2015 03:36:00 -0400
In-Reply-To: <1427740529-9605-6-git-send-email-vladz@cloudius-systems.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-rw04sEnCy42QMkbrJ2cE
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Mon, 2015-03-30 at 21:35 +0300, Vlad Zolotarov wrote:
> For 82599 and x540 VFs and PF share the same RSS Key. Therefore we
> will return
> the same RSS key for all VFs.
>=20
> Support for other devices will be added later.
>=20
> Signed-off-by: Vlad Zolotarov <vladz@cloudius-systems.com>
> ---
> New in v10:
>    - Return more self-explaining values.
>=20
> New in v9:
>    - Reduce the support to 82599 and x540 devices only.
>    - Get rid of registers access in GET_VF_RSS_KEY flow:
>       - Get the RSS HASH Key value from the PF's adapter->rss_key[].
>=20
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
>  drivers/net/ethernet/intel/ixgbe/ixgbe_mbx.h   |  1 +
>  drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.c | 21
> +++++++++++++++++++++
>  2 files changed, 22 insertions(+)

Thanks Vlad, applied to my queue.
--=20
git://git.kernel.org/pub/scm/linux/kernel/git/jkirsher/next-queue.git
dev-queue

--=-rw04sEnCy42QMkbrJ2cE
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAABCgAGBQJVGk5fAAoJEOVv75VaS+3Ow1UQAJGERa0nimupHt3ylyRO0Gwr
EagHo4OWiMjFp3zJbalZekP1XBRKbPx0hUW/PoTGYXBKOnNjdAlGO9fQj33V0NE1
UNnnCxKONwPjeBGqp/eUzM7mraZg3AhN0ZlZxkpFBKtKpIoIFK7TPShaNCnO/agP
JVn9YqohvI9AvpqaAN5efla2W6wbf4hZTkhOw7XA3eim8LCGSriWTF/oRVttw43B
+amuWhaQ03qIpf9Cu32UytUQSSpPm+fXxUtEoaXj7IBfyPohx2ifndLJOg7FZhq6
sGrnmwSrNWFm/PJkIFGkW7BHipiSBMFCXrYqb/6qFqU6qZ2maYQuivTeVWcshttH
fdhqa07O5u0Vekjlxk9R1zhl8dCPVUYlIO3lxUL3O5fjq6GSBnHi7N14n34kwr9i
gkX+niHw5Fcu4De2QxAN9j4EzW4urxEAf/xSeN942QJJj58vg4VNhpUF2OyntEwP
7IaGnSApPGKQbvSW0B+rL7X6jxqyUqXDqbG1zouZhIcWHdwD33/A79iYbyJky+dP
4CU4+pc+1Je5OwZf0vIf7/cX1Qh9ZhR0Mxcg1IuRpHlIppjy4zsCZsHhl1v/aWYv
gakxhn0r6SOVnC10NOcxawdxTqXakPBn7z6NGcyOr8Cpwy7xuu7CZxFCkfD7Qfaj
baqBSGhcJn0yopqJ1UZZ
=mis6
-----END PGP SIGNATURE-----

--=-rw04sEnCy42QMkbrJ2cE--
