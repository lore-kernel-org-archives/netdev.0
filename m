From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [PATCH net-next v1 0/5]: ixgbevf: Allow querying VFs RSS
 indirection table and key
Date: Wed, 31 Dec 2014 08:01:40 -0800
Message-ID: <1420041700.31582.36.camel@jtkirshe-mobl>
References: <1420019519-18139-1-git-send-email-vladz@cloudius-systems.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-RvckQV6yR+It+x11ZITZ"
Cc: netdev@vger.kernel.org, gleb@cloudius-systems.com,
	avi@cloudius-systems.com
To: Vlad Zolotarov <vladz@cloudius-systems.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:9002 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750760AbaLaQBm (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 31 Dec 2014 11:01:42 -0500
In-Reply-To: <1420019519-18139-1-git-send-email-vladz@cloudius-systems.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-RvckQV6yR+It+x11ZITZ
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Wed, 2014-12-31 at 11:51 +0200, Vlad Zolotarov wrote:
> Add the ethtool ops to VF driver to allow querying the RSS indirection
> table
> and RSS Random Key.
> =20
>  - PF driver: Add new VF-PF channel commands.
>  - VF driver: Utilize these new commands and add the corresponding
>               ethtool callbacks.
>=20
> New in v1 (compared to RFC):
>    - Use "if-else" statement instead of a "switch-case" for a single
> option case.
>      More specifically: in cases where the newly added API version is
> the only one
>      allowed. We may consider using a "switch-case" back again when
> the list of
>      allowed API versions in these specific places grows up.

Thanks Vlad, I will add your series to my queue.

--=-RvckQV6yR+It+x11ZITZ
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAABCgAGBQJUpB3kAAoJEOVv75VaS+3Odf4P/36ENhMG99hQwxhS5lFlE2cd
zZxRFVA88qjNfdTIrW30um6iEVjuHmcGJFWfi5ixlLChaDovEZr9CmABEPKaf1K4
JnyLfAeuelpylw99sKaS1LHmvdqMZx0hZYELXb4ZjxEES5i3Tk0cpMNIB2+CEfyk
zXKRzqJmAzyx3pKmtdCb35mizKuXtJaT7uDrMJKspEHpITUV3UfIb4bRhsIVr2p2
uZqxefILsLPKbbHZ2nWSn6qJleCKRWkJLWIPTNfZFavloazoysd68EYcZjyqjzzH
xVds0Oxsq5bXf4vAHLXfF+b3GT0kTCseniERAFmPgUGdyVbtnxwDDTpIOKliyMyA
AZVGl4CgrbRJVtnZSQln1vzKXEf1pyWsnic1FkT4Pn7tcI3phODuSqBG8lUjPh/A
oG+CllGkMpaUQcjjoAbYcIX4yGTQytu9Zdwf5E1LAzmLSsonvTyDNlQicFbHaFu0
EveP9aTK3Ia+tpTBMcuwmWP1a04ZVRm1KK/xtKCfMO9pjTgugVc1+a9O404OxLbX
2OJgZdKr2iviASnslfqcvl133K5hjDFMqyWb2SHxgVqWGKCrevyNRPHh2GH3JtL0
TGSSzozwLg00yAaO0ZOuC0yNxZtxCQ5ZpzbvXhb3SKzwrP4vO4DwxP2nuEUbLdVE
CxG7FOC5sRJ5Pc+m8O7u
=LJAV
-----END PGP SIGNATURE-----

--=-RvckQV6yR+It+x11ZITZ--
