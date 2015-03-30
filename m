From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [PATCH net-next v3 1/2] ixgbe: Refactor the RSS configuration
 code.
Date: Mon, 30 Mar 2015 16:36:46 -0700
Message-ID: <1427758606.2497.100.camel@jtkirshe-mobl>
References: <1427739538-1038-1-git-send-email-vladz@cloudius-systems.com>
	 <1427739538-1038-2-git-send-email-vladz@cloudius-systems.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-ynrM1tJHfkodsjLcMc2/"
Cc: netdev@vger.kernel.org, intel-wired-lan@lists.osuosl.org,
	avi@cloudius-systems.com, gleb@cloudius-systems.com
To: Vlad Zolotarov <vladz@cloudius-systems.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([192.55.52.115]:5530 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751034AbbC3Xgr (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 30 Mar 2015 19:36:47 -0400
In-Reply-To: <1427739538-1038-2-git-send-email-vladz@cloudius-systems.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-ynrM1tJHfkodsjLcMc2/
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Mon, 2015-03-30 at 21:18 +0300, Vlad Zolotarov wrote:
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
> New in v3:
>    - Fix the byte ordering in RETA storing.
>=20
> New in v2:
>    - Some styling fixes.
>    - Moved macros definitions from ixgbe_type.h to ixgbe.h.
> ---
>  drivers/net/ethernet/intel/ixgbe/ixgbe.h      |   9 ++
>  drivers/net/ethernet/intel/ixgbe/ixgbe_main.c | 147
> ++++++++++++++++++--------
>  2 files changed, 112 insertions(+), 44 deletions(-)

Thanks Vlad, I have added your patch to my queue.
--=20
git://git.kernel.org/pub/scm/linux/kernel/git/jkirsher/next-queue.git
dev-queue

--=-ynrM1tJHfkodsjLcMc2/
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAABCgAGBQJVGd4OAAoJEOVv75VaS+3O+kQQAIq9K5+kxbAssekWZW62/lw3
rPCgFjSbsMPXWA9ZbLub2zD0N4plO/ugkvrc4o/FN6BcvZNLq3CxzYpkwNzb1/8r
yw50jo2YlD9tcM/chPRdYqkjAMaNqBkaYiFoEPfvdL5e7XtgOT+Fv25qySBJE65d
9t246T6JaHdMqB4Ec1FdalqcfINZbapxiY/OX/vuAV0cxmUQ6X1UY/g1AAGMB5XY
EfFNvS7+7eRDATO++RzOiayk1JDw+2NGsrtN6p38WIgpvHI+qsKbali+BLLQg8yM
ceCvaiwOD0SqnLhIpmYKv5ioSDXTXFBac/gyrlUGsqUb251DQd8knt8vfMDMpD1F
U0D30fKQX+AfKjIwSXRc2CIJvQX1OG27i5MG750VCaD50iWTPosssG+SluQ1MssV
JxVSjZY0ETEpTTfkCQQgR9NPrrp2ufJuVbp7hxUt32EjcRG2+Igj+TzeQeB3nufx
j7M6s4QTplGZkvEavKrBU2muDFhawzj0L0pJmAZst5E25dv19ov9AaPkuXp4mjuM
6sXFMiGjKoO3qR1Aw9W6/UOyS0J5M4YfMtPG6VdBVbe2kbohBWpkFhh4VE4hcJi4
m4waxWBbug4mjuLrxJUQ1MGZiWd4OEx0uZGqiMesRL0XO8eqZggAmF85AwTlBI0Y
4mhkmiKfDfu+NXS3j2Rw
=T5me
-----END PGP SIGNATURE-----

--=-ynrM1tJHfkodsjLcMc2/--
