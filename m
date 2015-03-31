From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [PATCH net-next v10 2/7] ixgbe: Add a new netdev op to
 allow/prevent a VF from querying an RSS info
Date: Tue, 31 Mar 2015 00:35:11 -0700
Message-ID: <1427787311.2497.110.camel@jtkirshe-mobl>
References: <1427740529-9605-1-git-send-email-vladz@cloudius-systems.com>
	 <1427740529-9605-3-git-send-email-vladz@cloudius-systems.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-6oV4pF+unrwe7lOVqGwg"
Cc: netdev@vger.kernel.org, intel-wired-lan@lists.osuosl.org,
	avi@cloudius-systems.com, gleb@cloudius-systems.com
To: Vlad Zolotarov <vladz@cloudius-systems.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:21975 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752131AbbCaHfM (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 31 Mar 2015 03:35:12 -0400
In-Reply-To: <1427740529-9605-3-git-send-email-vladz@cloudius-systems.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-6oV4pF+unrwe7lOVqGwg
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Mon, 2015-03-30 at 21:35 +0300, Vlad Zolotarov wrote:
> Implements the new netdev op to allow user to enable/disable the
> ability
> of a specific VF to query its RSS Indirection Table and an RSS Hash
> Key.
>=20
> This patch limits the new feature support to 82599 and x540 devices
> only.
> Support for other devices will be added later.
>=20
> Signed-off-by: Vlad Zolotarov <vladz@cloudius-systems.com>
> ---
> New in v10:
>    - United the for-each-VF loops in __ixgbe_enable_sriov() and
>      ixgbe_configure_virtualization().
>    - Use the EOPNOTSUPP error code instead of EPERM when operation is
>      not supported.
>=20
> New in v9:
>    - Reduce the support to 82599 and x540 devices only.
> ---
>  drivers/net/ethernet/intel/ixgbe/ixgbe.h       |  1 +
>  drivers/net/ethernet/intel/ixgbe/ixgbe_main.c  |  5 ++++
>  drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.c | 34
> ++++++++++++++++++++++++--
>  drivers/net/ethernet/intel/ixgbe/ixgbe_sriov.h |  2 ++
>  4 files changed, 40 insertions(+), 2 deletions(-)

Thanks Vlad, applied to my queue.
--=20
git://git.kernel.org/pub/scm/linux/kernel/git/jkirsher/next-queue.git
dev-queue

--=-6oV4pF+unrwe7lOVqGwg
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAABCgAGBQJVGk4vAAoJEOVv75VaS+3O/HUP/jH2oa8CqGI8PsF8eWZoy9F6
zlQNAku9/G3YutHAB6er8qt3WlU8FmtWcetQfVK+1i9MKA/V32AiFZcS2UKxHnM8
78xaqdjPMNHHgtAmZ3a+Pgf27pILPPFOIQ/t1IJnfvfF6TlzoGb3tT7V8AhS2AiP
zX8Rw9LHPqswM/big8m9vQ7dbJxkYs8nE8AmzcL+Ykchx2aKbNFWnFIcg3dAueN2
M7ibRr2KDJZJRrgoS/A2q0f08ar83iFrHO2kTD5zHePafaC5g3G6J6HPIVXKWsZV
nTVdRaHjUcyihVA2ku+HXrxhLAWSqcoqNsPnWj7y67RuawxkF1bfFgNvGkGlo5J8
e0fHV1GS4ojKzpLrHOdeVhx+v9A1KZuWy3aEOa/chYz5XUkLwGjTs9X8diP6Qenz
t6Y5Dj0Cl21MIdxuGdj1S3GR2GHFT3rtHj6M9MsEkn4SCStI3H8Ejb7Th1dq1fr+
RMoo6HCMJxyJbXhYTIRUTlFoXHmOt7pZWKIin/jVT5k/uWN4EPpR7BSvqt9eyDlr
qRDAKTwfc0HzlZadxjp719vjVzRxQ3fLz5kifJFxqnXZjI0/Q5VXLe3ka7hpqs+F
d+w8cb+ngFMzxhESTdfv2f04pc56Xgw2HCDjsJRQMy9b0E8K6cxq86sKs5boKBsp
EigomEBehvc3ZYZx+vGG
=baJ5
-----END PGP SIGNATURE-----

--=-6oV4pF+unrwe7lOVqGwg--
