From: Mark Brown <broonie@kernel.org>
Subject: Re: next-20170110 build: 1 failures 4 warnings (next-20170110)
Date: Tue, 10 Jan 2017 18:16:07 +0000
Message-ID: <20170110181607.dp6giaxyeczykmv4@sirena.org.uk>
References: <E1cQqkO-0005XB-2K@optimist>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
        protocol="application/pgp-signature"; boundary="63sanvmh3yu7xdkw"
Cc: kernel-build-reports@lists.linaro.org,
        linaro-kernel@lists.linaro.org, linux-next@vger.kernel.org,
        linux-arm-kernel@lists.infradead.org, netdev@vger.kernel.org
To: Michael Scherban <m-scherban@ti.com>,
        Murali Karicheri <m-karicheri2@ti.com>,
        Sekhar Nori <nsekhar@ti.com>,
        "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mezzanine.sirena.org.uk ([106.187.55.193]:41410 "EHLO
        mezzanine.sirena.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1757542AbdAJSQW (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 10 Jan 2017 13:16:22 -0500
Content-Disposition: inline
In-Reply-To: <E1cQqkO-0005XB-2K@optimist>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--63sanvmh3yu7xdkw
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

On Tue, Jan 10, 2017 at 07:21:32AM +0000, Build bot for Mark Brown wrote:

Today's -next fails to build an arm allmodconfig due to:

> 	arm-allmodconfig
> ../drivers/net/ethernet/ti/netcp_core.c:1951:28: error: initialization from incompatible pointer type [-Werror=incompatible-pointer-types]

caused by 6a8162e99ef344 (net: netcp: store network statistics in 64
bits).  It's assigning the function

  static struct rtnl_link_stats64 *
  netcp_get_stats(struct net_device *ndev, struct rtnl_link_stats64 *stats)

to ndo_get_stats64 which expects a function returning void.

--63sanvmh3yu7xdkw
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQEzBAABCAAdFiEEreZoqmdXGLWf4p/qJNaLcl1Uh9AFAlh1JOYACgkQJNaLcl1U
h9D51Qf+KwriZ5/QHLVpchJX7ozC75aiZOua8cRooPNuldRsfCbB/CCKfk2HcZ7J
/BvsRfhtuLFZS1OUYuJT6G3KnkjQg9byHM0QZVRKqFsZNGCO+P0QDidtmp8sYmEU
WxuZy2UJXk8PIa2SQzWPxQs8LS/ttOesndlrqY/vYenqwGcbCvn3FnZHzA129v/C
n5WnLIW+YVITAKhi23uDhAreqHqNc4iaYtIqxHtVv9YM3VOs4aqjilbbMugSqjjT
ZqWi7ACqq2uquhIQeHnB23FLQwK4UQNyDyZOuAbNlZ1E0OQiUDw4GwsLwlYvb89W
4WaTEYzqg3xySGrKj8Pgc/BtGsbegw==
=dWbS
-----END PGP SIGNATURE-----

--63sanvmh3yu7xdkw--
