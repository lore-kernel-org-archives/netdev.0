From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [net-next PATCH 1/2] ixgbe: use u32 instead of __u32 in model
 header
Date: Wed, 17 Feb 2016 14:41:48 -0800
Message-ID: <1455748908.2958.22.camel@intel.com>
References: <20160217223453.9858.76096.stgit@john-Precision-Tower-5810>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-IxwYB6YZtYMowVnK+GwS"
Cc: netdev@vger.kernel.org, davem@davemloft.net
To: John Fastabend <john.fastabend@gmail.com>, jhs@mojatatu.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([192.55.52.115]:52521 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1423809AbcBQWmH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 17 Feb 2016 17:42:07 -0500
In-Reply-To: <20160217223453.9858.76096.stgit@john-Precision-Tower-5810>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-IxwYB6YZtYMowVnK+GwS
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Wed, 2016-02-17 at 14:34 -0800, John Fastabend wrote:
> I incorrectly used __u32 types where we should be using u32 types
> when
> I added the ixgbe_model.h file.
>=20
> Fixes: 9d35cf062e05 ("net: ixgbe: add minimal parser details for
> ixgbe")
> Suggested-by: Jamal Hadi Salim <jhs@mojatatu.com>
> Signed-off-by: John Fastabend <john.r.fastabend@intel.com>
> ---
> =C2=A0drivers/net/ethernet/intel/ixgbe/ixgbe_model.h |=C2=A0=C2=A0 18 +++=
++++++-----
> ----
> =C2=A01 file changed, 9 insertions(+), 9 deletions(-)

Acked-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

Dave feel free to pull this series in from John to fix the issues with
his previous series.
--=-IxwYB6YZtYMowVnK+GwS
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIcBAABCgAGBQJWxPcsAAoJEOVv75VaS+3OIDcP/3DK4cTzC2zW8xNPDKebmn3N
UQ8ygOl5ajotH+ZdkUltN+5qqhF3spMx7clOiY63AaLaCtu+722oXE0EMjGR3oW/
q/LeZ8cCyFe/Eny2oAKcTR97zHTQHWMgQZr5fkYQZsj7P738kAxfHwyEbhhhYDSU
LAFwu4RtThTX+ekCuqif9LrIaPOVG4slCPorN4laBiCPv3vSpYq5Wzck8tKudHuy
FKeNDBKtC0BQEze13+y303j5o3SHATF+gvAD3gart9LedvUjFKJ6rAKxfsDngRmP
flltgse1ckPP9jMIqTac9UCAaN/kK6C/W94LjT+rJTPFydFVm2WY7uV387wQV5LH
EY8a530jlgD9eEeMdm3LPpt3ieRNvI1jQ67azRMeN5Zh/061638TreHb/b1tTXiG
bXiMKca4hrd6kF+gEuBBiRRkVk/SkiEx0l+9DSKKaoaoLniIxEhnpfSmR0tjvW1w
oVI5FNbv6Tq866r+FOHkaBemLOzUD9y7BW9IYU14pkqWooo0Gz6bOGyY4LLL0Mii
xzfOpgwaw2haBYBSM8A5o0Z6XVqA8kHGvYDlxYsQp02mG2pE9wrbe/4WARlRJqmE
QJefuFEz3IDpRpqhqMjaDn19Q5yFwGHPYg63psmajNIWzlDY5mbmEvJQhCx3lyA2
CMPy2vbLPdRZQHjlEZuo
=w2Dm
-----END PGP SIGNATURE-----

--=-IxwYB6YZtYMowVnK+GwS--
