From: Mark Brown <broonie@kernel.org>
Subject: linux-next: manual merge of the rdma tree with the FIXME tree
Date: Fri, 13 Oct 2017 11:18:06 +0100
Message-ID: <20171013101806.vqcbv2sop2r4wsrk@sirena.co.uk>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
        protocol="application/pgp-signature"; boundary="wp5nohmpfdhnln5a"
Cc: netdev@vger.kernel.org,
        Linux-Next Mailing List <linux-next@vger.kernel.org>,
        Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
To: Doug Ledford <dledford@redhat.com>,
        "David S. Miller" <davem@davemloft.net>,
        Allen Pais <allen.lkml@gmail.com>,
        Kees Cook <keescook@chromium.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from heliosphere.sirena.org.uk ([172.104.155.198]:42260 "EHLO
        heliosphere.sirena.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1757058AbdJMKSN (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 13 Oct 2017 06:18:13 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--wp5nohmpfdhnln5a
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi Doug,

Today's linux-next merge of the rdma tree got a conflict in:

  drivers/net/ethernet/mellanox/mlx4/catas.c

between commit:

  d2a0012e7632a5 ("drivers: net: mlx4: use setup_timer() helper.")

=66rom the net-next tree and commit:

  55c0fcc3de4605 ("net/mlx4_core: Convert timers to use timer_setup()")

=66rom the rdma tree.

I fixed it up by taking the second commit and can carry the fix as
necessary. This is now fixed as far as linux-next is concerned, but any
non trivial conflicts should be mentioned to your upstream maintainer
when your tree is submitted for merging.  You may also want to consider
cooperating with the maintainer of the conflicting tree to minimise any
particularly complex conflicts.

--wp5nohmpfdhnln5a
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQEzBAABCAAdFiEEreZoqmdXGLWf4p/qJNaLcl1Uh9AFAlngkt0ACgkQJNaLcl1U
h9AVrgf+PuLxss5Zfg63+7HHydD/JT+sPj0GpIDyoBAEBO3tMx+3xwBSLBjr5hjB
LM9ImPnSqlAply4fbDpozq1l/CTXyxDvt/5KaESUNV6OZllkIbdwjkU5elQXwyCQ
DvJJIDTtO+fqJFllVCG9AsU90kFxQQhMPMQosWNstGQ5X1wYyo6ycRk4sSwMnC21
/UdJeSH+X1P2v1wMsszuW3cffVZWkBVcv7IW0JTJmTnsgeQm67wwBcVi672GEh60
EyxE6PqEDjoc98azDb8Xt+jW0dE74Sk0MidrxQEUL/IROgf2D32Jp+FnFpVFZpuX
x4QZHl8PGIx/nhHsxxI5IpmxaNgZCw==
=5zax
-----END PGP SIGNATURE-----

--wp5nohmpfdhnln5a--
