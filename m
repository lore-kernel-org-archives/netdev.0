From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [PATCH] i40e: avoid use of uninitialized v_budget in
 i40e_init_msix
Date: Tue, 13 Jan 2015 11:03:13 -0800
Message-ID: <1421175793.2528.7.camel@jtkirshe-mobl>
References: <1421174908-20445-1-git-send-email-linville@tuxdriver.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-gLxfTeexYWphPFMcIc8O"
Cc: netdev@vger.kernel.org, Linux NICS <linux.nics@intel.com>
To: "John W. Linville" <linville@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:4963 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753402AbbAMTEQ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 13 Jan 2015 14:04:16 -0500
In-Reply-To: <1421174908-20445-1-git-send-email-linville@tuxdriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-gLxfTeexYWphPFMcIc8O
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Tue, 2015-01-13 at 13:48 -0500, John W. Linville wrote:
> This I40E_FCOE block increments v_budget before it has been
> initialized,
> then v_budget gets overwritten a few lines later.  This patch just
> reorders the code hunks in what I believe was the intended sequence.
>=20
> Coverity: CID 1260099
>=20
> Signed-off-by: John W. Linville <linville@tuxdriver.com>
> ---
> Compile tested only...
>=20
>  drivers/net/ethernet/intel/i40e/i40e_main.c | 10 +++++-----
>  1 file changed, 5 insertions(+), 5 deletions(-)

Thanks John, I will add your patch to my queue.

--=-gLxfTeexYWphPFMcIc8O
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAABCgAGBQJUtWvxAAoJEOVv75VaS+3OzFYP/RfKrPnG0lBjxhZH+SO/CMwL
jBOUdzD+VgdjeMpRDY8TcwZBObyBi+zNCjnPwCL8Wy1Wqq9DQvK2uEQ6DSbOVh02
66hGnQQXgNcrhaNnYT3/orD62FmA4g1C+Gq7vh+Q8AF8GjyAbLjOWAmjfM7m2oQw
2UD4H2BYZLAP6cqiP9ssjGQTlPSYebWuPhqHfvz4aAOW23pKvBOn+ZAZrJpSBN5S
B9uiUhbbt9176jbLjZtQxy13ifuM3aYJ9Jyij1fL4MbAXnCD4kjGeYFBMubEu6eU
r9JR7HHKrDshU+C2tbgowgvPL6LdSLyR232t0IqnJ6pkov9z8J6uqnJxPwMiIJi1
hxYHgFkH+4GUTw1qzq6ZfPyvM+5FfQjaIS1L/enD2gaPvxrzimXod9V+ZBNpWdSE
E0XLF1gegrUVNs24XK9q6WJgCtEjuokrZ+7W5+BTY1uPp0fivl2Cu5GkVw5nN562
Ug72m4RfZAF9F2A2PQkZvSSwTjSo9txi2RqGETyYOCrMgmKSDG9vXjpMqThzNJtl
Iq7zrtSjKb2OQhEeKoh6vcrhDm6NeoerS2QjME5Cf8lcuQh7JzZOtFo1GDiJPmoi
A1szV0pvAwbtkrwcOOC5Urf2viCOC/f0VZd7r8ncZhjoI3EI7aXgY8refDsSlHWG
jbdpc5pFtny8hEeMiIpP
=q9za
-----END PGP SIGNATURE-----

--=-gLxfTeexYWphPFMcIc8O--
