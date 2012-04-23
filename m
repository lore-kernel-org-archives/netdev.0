From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [PATCH 2/2] e1000e: Remove special case for
 82573/82574 ASPM L1 disablement
Date: Mon, 23 Apr 2012 16:18:39 -0700
Message-ID: <1335223119.2783.13.camel@jtkirshe-mobl>
References: <1335216578-21542-1-git-send-email-bootc@bootc.net>
	<1335216578-21542-3-git-send-email-bootc@bootc.net>
Reply-To: jeffrey.t.kirsher@intel.com
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============3639331048514413585=="
Cc: e1000-devel@lists.sourceforge.net, netdev@vger.kernel.org,
	nix@esperi.org.uk, linux-kernel@vger.kernel.org
To: Chris Boot <bootc@bootc.net>
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
In-Reply-To: <1335216578-21542-3-git-send-email-bootc@bootc.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org


--===============3639331048514413585==
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-12bCDlL8Kf2mXAWXMILL"


--=-12bCDlL8Kf2mXAWXMILL
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Mon, 2012-04-23 at 22:29 +0100, Chris Boot wrote:
> For the 82573, ASPM L1 gets disabled wholesale so this special-case
> code
> is not required. For the 82574 the previous patch does the same as for
> the 82573, disabling L1 on the adapter. Thus, this code is no longer
> required and can be removed.
>=20
> Signed-off-by: Chris Boot <bootc@bootc.net>
> ---
>  drivers/net/ethernet/intel/e1000e/netdev.c |    8 --------
>  1 file changed, 8 deletions(-)=20

I have added the patch to my queue, thanks Chris!

--=-12bCDlL8Kf2mXAWXMILL
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.12 (GNU/Linux)

iQIcBAABCgAGBQJPleNPAAoJEOVv75VaS+3Od3MP/2/zlsipy1dwhS4+fRgXs7VI
B0Ja9znrcKBqOsrJ9gGCXKYt15NDN8O320E0xupdkgBQF/A0V2nl8EUiIqyilGVd
mcrQ2RFIOeTPexhLy83VCeZ+4HMc8s6+mHFLhrcuWNU/oAEgRNYXmW3/slT/p3dj
1VhEcTD8PqiWXrklgncgbi43sry++SyKxdoRfNkjzh9CPcmAupHKcRMSc+Kc45Rl
sHl2m+FUz7H4Qzs1Kwh5FiKkvPzH6IRpXFbn4wMlUAwSfjE0LALNFKu8zRcrrfv7
PrLZGo7S9uUIKUe15Ts71pbN6XSQ/n3F5zZdUk1Eq1adDBd3LzrJFjxZMMwZ85py
SkV/rjU3zGkGyd9nZmZ4nkiu82G1uHAx5WUGg9ehXJAm7EPY321T/mRrsQ0M5+Ql
PEKfj3qwVZMv9yfI9Xd1pmZ9cIievHdyJDYXP1UuFrL6ohQ8CjhvdKVo61ffGWna
4cWLs2lMIeDpyWwu/JtIFOcv/jKtTC8y0Uy5JEfbLIO+2dJz09HdsjtoBjBUcaOe
VPwOsFgpqLzHlJxAz4JGlTfsweDceqs2uV1G5CkFYYjqEb/YrqfE3ldsbDXgK2vn
IB+zklqMW+lGhR8bzo5SwgDptHyDw4fB0VATlCKZyIQJx+IsQhlcqPWuDo9/pHU/
oG4b953YmIwn5CqLyg28
=E2gW
-----END PGP SIGNATURE-----

--=-12bCDlL8Kf2mXAWXMILL--



--===============3639331048514413585==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

------------------------------------------------------------------------------
For Developers, A Lot Can Happen In A Second.
Boundary is the first to Know...and Tell You.
Monitor Your Applications in Ultra-Fine Resolution. Try it FREE!
http://p.sf.net/sfu/Boundary-d2dvs2

--===============3639331048514413585==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
E1000-devel mailing list
E1000-devel@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/e1000-devel
To learn more about Intel&#174; Ethernet, visit http://communities.intel.com/community/wired

--===============3639331048514413585==--
