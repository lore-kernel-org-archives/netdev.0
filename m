From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [PATCH iproute2] ip link set vf: Added "query_rss" command
Date: Mon, 23 Mar 2015 03:42:41 -0700
Message-ID: <1427107361.2577.173.camel@jtkirshe-mobl>
References: <1427050378-15004-1-git-send-email-vladz@cloudius-systems.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-321SguJMNlT2zAFMEpZG"
Cc: stephen@networkplumber.org, kuznet@ms2.inr.ac.ru,
	netdev@vger.kernel.org
To: Vlad Zolotarov <vladz@cloudius-systems.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:60058 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752104AbbCWKmm (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 23 Mar 2015 06:42:42 -0400
In-Reply-To: <1427050378-15004-1-git-send-email-vladz@cloudius-systems.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-321SguJMNlT2zAFMEpZG
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Sun, 2015-03-22 at 20:52 +0200, Vlad Zolotarov wrote:
> Add a new option to toggle the ability of querying the RSS
> configuration of a specific VF.
>=20
> VF RSS information like RSS hash key may be considered sensitive on
> some devices where
> this information is shared between VF and PF and thus its querying may
> be prohibited by default.
>=20
> This new option allows a system administrator with privileges to
> modify a PF state
> to control if the above VF querying is allowed or not.
>=20
> For example:
>  To enable RSS querying of VF[0] of ethX:
>  >> ip link set dev ethX vf 0 query_rss on
>=20
> Signed-off-by: Vlad Zolotarov <vladz@cloudius-systems.com>
> ---
>  include/linux/if_link.h |  8 ++++++++
>  ip/iplink.c             | 13 +++++++++++++
>  2 files changed, 21 insertions(+)

I have added your other patch series to my next-queue tree for further
review and testing.  I have also made validation aware of this patch to
properly review your changes, thanks Vlad.

--=-321SguJMNlT2zAFMEpZG
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAABCgAGBQJVD+4hAAoJEOVv75VaS+3OQDMP/j/2yAdBmQhF8WYHXipK/efK
cv5D7eTGBTnXEBisHTIqYJaLekcwl84UMdtT+qckJc4LYR+mF0AUTCnwtbP7OXGS
L0lQxlycfJktWrt0pLK3Hgq1zSocwMetjOpB/rWwSS9bVvRnSlb0ZVp3HuXdrg6s
Gd6JopIvRI7IvlOYtg0fm0y2XDMSXV8e+rkld2yCOlHfHzBDUMineJX0668zJ+zx
3JT9e52D7MC7arRlhfzgJeDLfpYL3LNJPj8wXn65E0DmUOPYlaj54ljqKXg8+p/g
pZMT0/+vNwWZha+6asbSvX1XyZc4+upM9QSwn63hztVym6aFqVurfY283iKLY0lb
ormIi96YbgINQnX9YCRMwggYp6vuirHaGwOy+K/t0WL5WraP9gXLfLl9NNCvFjzz
SpCKCGz5IzynjZv5/60UoxS1x6mqvFPW5AjKmW7EAzuy6j0PeWcwooqVRdKArD4n
SYBzcJ4uEKi4DXglOgqZ4aSn+8fSn8FPLr3/IrIVjO3lZH5xTfrTJT5LRA+SAz8i
Ajvj7qeftCDU1wqrxIz9kKouaa50vePegfbG3sV8/QqyH5ATUXMQCjN7nkDKlK6W
OGV/oIAdoUXIpBPyLFC0tE49NQhvWnngahXRyaI8OlgESRyezBERgnaUEQkZktn0
SfUC1fW04SbNkT0SCHf2
=/MQv
-----END PGP SIGNATURE-----

--=-321SguJMNlT2zAFMEpZG--
