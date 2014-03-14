From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [PATCH net-next 06/10] ixgbe: fix race conditions on queuing
 skb for HW time stamp
Date: Fri, 14 Mar 2014 16:18:02 -0700
Message-ID: <1394839082.2167.92.camel@jtkirshe-mobl>
References: <1394818481-7652-1-git-send-email-kubakici@wp.pl>
	 <1394818481-7652-7-git-send-email-kubakici@wp.pl>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-1vdEd6cNugemEJqRTGid"
Cc: netdev@vger.kernel.org, e1000-devel@lists.sourceforge.net
To: Jakub Kicinski <kubakici@wp.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:3099 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755451AbaCNXSE (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 14 Mar 2014 19:18:04 -0400
In-Reply-To: <1394818481-7652-7-git-send-email-kubakici@wp.pl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-1vdEd6cNugemEJqRTGid
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Fri, 2014-03-14 at 18:34 +0100, Jakub Kicinski wrote:
> ixgbe has a single set of TX time stamping resources per NIC.
> Use a simple bit lock to avoid race conditions and leaking skbs
> when multiple TX rings try to claim time stamping.
>=20
> Signed-off-by: Jakub Kicinski <kubakici@wp.pl>
> ---
>  drivers/net/ethernet/intel/ixgbe/ixgbe.h      | 1 +
>  drivers/net/ethernet/intel/ixgbe/ixgbe_main.c | 4 +++-
>  drivers/net/ethernet/intel/ixgbe/ixgbe_ptp.c  | 3 +++
>  3 files changed, 7 insertions(+), 1 deletion(-)

Thanks Jakub, I will add this patch to my queue.

--=-1vdEd6cNugemEJqRTGid
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIcBAABCgAGBQJTI44qAAoJEOVv75VaS+3OXhEP+gIyzuRQICQRkGGt3N3n8f3B
C9/UF9NOEsZiGMn7AwjVseAmL/rKoXqYuWvfh/IehVSiTKUss2E3uKgez3/FwW5h
D/91tXBLdUfNSlzuWGZUIFBF3kYKGeu0eBfLEHOfE0PyC7BDE+L/SuIlC0VoIeJ2
ZpV5uIA1xx7NuwwFbdzIOydp1vOeIn8fVElBzFKZsnBtR+4cTIr06PhqK8G1lKy4
wwNL4jkJsXQU0iE9YjZZ8sVAdUJ8yS3LRt/v0px+AejZrXs5PLY21BQvGjOVY9Pb
P4LyOxeJQ1+UPwbfARnLlROWm6ZZ10aQ2X5nCpQr4igHsHzHohr8ukd5OOBUqReT
QnUA12uWYuI0UXGnJra9JhvkKDu7egXFQ89/7ZRiU1+vKstYLnAnyFvj102CGDU0
/e3/g+ld98R2zA4TZAHaNPKehJ3k3ySSKJ1ve8ZhUzXcKz1DnwW/cHA19fYIChfv
GYqmKNEDAAxLXD4JN7QfGFPw3y/eVCIdOP8H+MGvt6Ws/qI7anl7XNcKn4Gl1ER1
2IPqDds9T+uSTzVyR16Z7tXQ+XVvI/C/Xp8PraVbAckNoTZqOBcp/nwQPvRjrq1f
l1WLXkjYaN2V1D30130F47Wo/5NEItjhC3pVa1lhAmIgVHtnGuhcocgx5TOGgQMG
67SLdBfYw+XYur3nKHEB
=yjuZ
-----END PGP SIGNATURE-----

--=-1vdEd6cNugemEJqRTGid--
