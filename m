From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [PATCH] ethernet: e1000e: define lat_ns as u64 instead of s64
Date: Fri, 03 Apr 2015 02:42:39 -0700
Message-ID: <1428054159.2662.82.camel@jtkirshe-mobl>
References: <1428052673-16412-1-git-send-email-yanjiang.jin@windriver.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-a2z5vTcQUfYDgiF5fvUX"
Cc: bruce.w.allan@intel.com, john.ronciak@intel.com,
	netdev@vger.kernel.org, jinyanjiang@gmail.com
To: yanjiang.jin@windriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:10499 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752148AbbDCJmk (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 3 Apr 2015 05:42:40 -0400
In-Reply-To: <1428052673-16412-1-git-send-email-yanjiang.jin@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-a2z5vTcQUfYDgiF5fvUX
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Fri, 2015-04-03 at 17:17 +0800, yanjiang.jin@windriver.com wrote:
> From: Yanjiang Jin <yanjiang.jin@windriver.com>
>=20
> do_div() expects the type of "n" to be uint64_t, define "lat_ns" as
> u64 to
> avoid the below warning, also update its correlative operations and
> data.
>=20
> In file included from ./arch/powerpc/include/asm/div64.h:1:0,
>                  from include/linux/kernel.h:124,
>                  from include/linux/list.h:8,
>                  from include/linux/timer.h:4,
>                  from drivers/net/ethernet/intel/e1000e/e1000.h:29,
>                  from drivers/net/ethernet/intel/e1000e/ich8lan.c:59:
> drivers/net/ethernet/intel/e1000e/ich8lan.c: In function
> 'e1000_platform_pm_pch_lpt':
> include/asm-generic/div64.h:43:28: warning: comparison of distinct
> pointer types lacks a cast [enabled by default]
>   (void)(((typeof((n)) *)0) =3D=3D ((uint64_t *)0)); \
>                             ^
> drivers/net/ethernet/intel/e1000e/ich8lan.c:1016:4: note: in expansion
> of macro 'do_div'
>     do_div(lat_ns, speed);
>=20
> Signed-off-by: Yanjiang Jin <yanjiang.jin@windriver.com>
> ---
>  drivers/net/ethernet/intel/e1000e/ich8lan.c | 8 ++++----
>  1 file changed, 4 insertions(+), 4 deletions(-)

Added intel-wired-lan mailing list (used for patches like this)
Removed LKML ... (wrong mailing list to be mailing for patches like
this)
Removed e1000-devel ... (no longer used for kernel patches)
Removed linux.nics ... (no longer used for kernel patches)

Also removed Intel developers with no interest in e1000e patches ...

Thanks Yanjiang, I will add your patch to my queue.

--=20
git://git.kernel.org/pub/scm/linux/kernel/git/jkirsher/next-queue.git
dev-queue

--=-a2z5vTcQUfYDgiF5fvUX
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAABCgAGBQJVHmCPAAoJEOVv75VaS+3OCD0QAKLnsXN2c6KlyvNxefbuW6GH
/G+ufuh150JZYzjOTNVGa8AXXBbQh+PBrQzFi+h/ECTR7ibjBu5Me3ag9xDun5yF
qEBc9xCJTAzCBq7wdI5O5OzsIqHcjinsRHX1Q3mrs1KGrBdz+6U4DsAIkvEbHc5i
SHGePYIdcFkkeJvqLC6UFTR+ttqyf8VMCOFpkNeWS499qso4uBlyFBkjIN/XQ2Gw
+GYXzId11y0hiP5iJhXCjvHmiwqymdGYY53SLqLU7eERUP0VCSesvWczZG2TCjLC
/u0+tybe1k9z6e9d3g8vg1QHWKID8xHNZVhkAdnh5CAZHyZJsQlA8FqECAlk5e4D
xXLLCQx4hmKbtW6vt9yKXUHcuzZJn5mNxfvri7xalAAjULaQEssHXqdKnxk/E4aU
p+tmFmnVrxLHpsxYGG5AWef4GxrneE14UTf0Hz+u5KK4wqzet0akne6OyvzPGy2p
uNt45BzmBclCVe3mFmDmly9VU4U5GJN+dkeLFPwgS7pP8iD6+l+g+cQkTl66AvfP
2YqtJZcFBrh9zPewvHGuzirslKkr5J4qC5H5y1DiMTmNHVjuSvDJcrcNpYicLNdU
1WOVqBPK9Ivpoc4AJS57I+gr0WBt/9YliV2yaCEJzc51rYGIWHlTaJxCdbeTaVyu
vc1R/FMxRUL7fNXOb6C2
=yxin
-----END PGP SIGNATURE-----

--=-a2z5vTcQUfYDgiF5fvUX--
