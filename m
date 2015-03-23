From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [PATCH net-next v6 4/7] ixgbevf: Add a RETA query code
Date: Mon, 23 Mar 2015 03:31:10 -0700
Message-ID: <1427106670.2577.161.camel@jtkirshe-mobl>
References: <1427050887-19412-1-git-send-email-vladz@cloudius-systems.com>
	 <1427050887-19412-5-git-send-email-vladz@cloudius-systems.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-9W/OKSuizIsDHn4oefoU"
Cc: netdev@vger.kernel.org, avi@cloudius-systems.com,
	gleb@cloudius-systems.com
To: Vlad Zolotarov <vladz@cloudius-systems.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:55088 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752325AbbCWKbL (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 23 Mar 2015 06:31:11 -0400
In-Reply-To: <1427050887-19412-5-git-send-email-vladz@cloudius-systems.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-9W/OKSuizIsDHn4oefoU
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Sun, 2015-03-22 at 21:01 +0200, Vlad Zolotarov wrote:
>    - Added a new API version support.
>    - Added the query implementation in the ixgbevf.
>=20
> Signed-off-by: Vlad Zolotarov <vladz@cloudius-systems.com>
> ---
> New in v6:
>    - Add a proper return code when an operation is blocked by PF.
>=20
> New in v3:
>    - Adjusted to the new interface IXGBE_VF_GET_RETA command.
>    - Added a proper support for x550 devices.
>=20
> New in v1 (compared to RFC):
>    - Use "if-else" statement instead of a "switch-case" for a single
> option case
>      (in ixgbevf_get_reta()).
> ---
>  drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c |  4 +-
>  drivers/net/ethernet/intel/ixgbevf/mbx.h          |  8 ++
>  drivers/net/ethernet/intel/ixgbevf/vf.c           | 92
> +++++++++++++++++++++++
>  drivers/net/ethernet/intel/ixgbevf/vf.h           |  1 +
>  4 files changed, 104 insertions(+), 1 deletion(-)

Thanks Vlad, I have applied your patch to my next-queue tree
--=20
git://git.kernel.org/pub/scm/linux/kernel/git/jkirsher/next-queue.git
dev-queue

--=-9W/OKSuizIsDHn4oefoU
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAABCgAGBQJVD+tuAAoJEOVv75VaS+3OnxwP/2VconzjzUbNx80Fg4HgKCR1
Vh4nbWvzRLcoUHEz2XKhDIqjvKIjfFby2Lj+h4+JX+yCfkQltWQ/3hUsVpLTm5bf
uJhfO0NeBQ3JH2JFr189DpO/zSAU2KwQ8g/f7pl30el0HXWiZIPBxiXKrFAn/1GZ
JB+zZWKEuHqmmJLGU7LVoFpmLuJyrt9RyR2slOk/pVaDW7z8NI8dcJ8CLiSmGrJT
5sImG47dbsuFs1+Hw3lfaESKkckp8g0HUiM+2tfG9kFXT0tO8BxxKmekAbsOT7JT
+RDXmDDMJKygUKHK3gent7u5HeOzFSn8lAjNWcklvutfYY2eJf8GGmJ8aoV6pHUB
/AJNPv/wcSrvfZPwOFuEZ9fsBMyNwfxKUbEbCP3Fbe81duPg2I+939X0UYS6939a
h4gbFhnSyqOxOlLnT5eWw7q4Jc4/En41vdRWdJZGF5G+wr18t9cByTALHKOVhVsn
Dw3Me5cd3Ndn24xRz+TIANlh8GAI5fEUFt/6Fxomy62kbiutx6uLhimq8zH+2/up
NAwTd64STYWxpyWl16Eljj3ZTwJtAvFUOOkt8HjWnewJmuGq2AmeWiHG1SoYktRL
AHtrjxEdFHL4Txxq8pI7oWTIcZJhI8J/idjkZ4zThrOxP3PD3VVkvIrGCcir8pWI
3kYN2AakPH3E0+SICe01
=6QXV
-----END PGP SIGNATURE-----

--=-9W/OKSuizIsDHn4oefoU--
