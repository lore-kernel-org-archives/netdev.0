From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [net-next PATCH] ixgbe: Drop unnecessary call to rcu_barrier
Date: Mon, 30 Mar 2015 11:35:58 -0700
Message-ID: <1427740558.2497.91.camel@jtkirshe-mobl>
References: <20150330164138.1335.47547.stgit@ahduyck-vm-fedora22>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-u6zfkfL2+gZZYhSwcA4Z"
Cc: netdev@vger.kernel.org
To: Alexander Duyck <alexander.h.duyck@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:46881 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753325AbbC3SgU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 30 Mar 2015 14:36:20 -0400
In-Reply-To: <20150330164138.1335.47547.stgit@ahduyck-vm-fedora22>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-u6zfkfL2+gZZYhSwcA4Z
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Mon, 2015-03-30 at 09:41 -0700, Alexander Duyck wrote:
> The ixgbe driver hasn't used call_rcu to free the rings for some time
> now.
> Since that is the case the call to rcu_barrier can be dropped since
> calls
> to kfree_rcu don't require it.
>=20
> Signed-off-by: Alexander Duyck <alexander.h.duyck@redhat.com>
> ---
>  drivers/net/ethernet/intel/ixgbe/ixgbe_main.c |    2 --
>  1 file changed, 2 deletions(-)

Thanks Alex, I will add you patch to my queue.
--=20
git://git.kernel.org/pub/scm/linux/kernel/git/jkirsher/next-queue.git
dev-queue

--=-u6zfkfL2+gZZYhSwcA4Z
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAABCgAGBQJVGZeOAAoJEOVv75VaS+3OrbsQAKL4N0FDoyaANzOohB2DuNeW
MezkjVo1w8iVAr9OekfbJj8b8dYRM4okKLbIXcKjyAM4SLvF00Yv1Kisay7K4Yg7
q2xXXwmn7/XMZWD+pNFt0cLgeaBOGCioOyJ5eMEUGi9iHAF34SwEZ6A/+rUwJWbm
YSrxAAQdQGXRP4NO2wj5a+6w9I1CKy/k+oAu10Js4FFsPOzNmkVyN7/4NGsQUbt4
CRYciYGXhevPojuyOZeNsvMVwjzBwka8i61GmUu7mMQZdDfK5pZVQITP0HCIi8ns
J0fyaP8kR+BG3iJE4g5ZbFZfgjuUTsGPj0L648jS+ZdxpSGmLfwo803fcSkxf7kg
u0YL5jq4nm5NOzN0TC9k6r4mB4+P65azU1HgoU1HvxHtlbP7HVe1JCjgib8Gu37M
qTdhA2F66hfX2LBHLh4YV43MRm7t7YINpnADuQqwviLZ1QQXlPvHG9k2YEfit96K
9Ml5P5xT/ZIfJzuar+eUC/JVdgHoITP2v1JATOD3WXkVNmXHDixK3AXFrRaV6MqN
+NTrwH/D53a1DprbfBUTGhlooqoILhaNjRL1hvtO8yXG5xYkvvf4DhOEGqjTy5Cg
FdJeu/OJJZ6IF6g2h+0EoYJnOc/mcUaLoy/3b6GZZ6H+fKOia+w/YgsbyxgxIvyC
77In3wqq/n7tk9lOdand
=Y3A/
-----END PGP SIGNATURE-----

--=-u6zfkfL2+gZZYhSwcA4Z--
