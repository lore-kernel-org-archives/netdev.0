From: Leon Romanovsky <leonro@mellanox.com>
Subject: Re: [for-next 07/10] IB/mlx5: Use blue flame register allocator in
 mlx5_ib
Date: Fri, 6 Jan 2017 08:06:09 +0200
Message-ID: <20170106060608.GG15685@mtr-leonro.local>
References: <1483480528-22622-8-git-send-email-saeedm@mellanox.com>
 <20170105.145157.1792441048386916850.davem@davemloft.net>
 <CAL3tnx4H2HsGMH=caiobivvvs0AU9yrzCmVONOdUQ_j_JMfufA@mail.gmail.com>
 <20170105.150731.2097384465565543422.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
        protocol="application/pgp-signature"; boundary="0z5c7mBtSy1wdr4F"
Cc: <eli@dev.mellanox.co.il>, <saeedm@mellanox.com>,
        <dledford@redhat.com>, <netdev@vger.kernel.org>,
        <linux-rdma@vger.kernel.org>, <eli@mellanox.com>,
        <matanb@mellanox.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-eopbgr20072.outbound.protection.outlook.com ([40.107.2.72]:47812
        "EHLO EUR02-VE1-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S938042AbdAFGmG (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 6 Jan 2017 01:42:06 -0500
Content-Disposition: inline
In-Reply-To: <20170105.150731.2097384465565543422.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--0z5c7mBtSy1wdr4F
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

On Thu, Jan 05, 2017 at 03:07:31PM -0500, David Miller wrote:
> From: Eli Cohen <eli@dev.mellanox.co.il>
> Date: Thu, 5 Jan 2017 14:03:18 -0600
>
> > If necessary I can make sure it builds on 32 bits as well.
>
> Please do.

Dave,

I'm failing to understand the benefits of building mlx5 on 32 bits, and
see only disadvantages:
 * It is actual dead code without test coverage.
 * It misleads reviewers/customers by seeing code for 32 bits.
 * It adds compilation time for 32 bits platforms and "punishes" them
   for not relevant for them driver.

Why do you call removing all that as a "regression"?

 Thanks.

--0z5c7mBtSy1wdr4F
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIzBAEBCAAdFiEEkhr/r4Op1/04yqaB5GN7iDZyWKcFAlhvM9AACgkQ5GN7iDZy
WKfSNw/6Ak2edP6u4kV0fPceCPUOzxmz8810K+3saY061bSgfIa3J09LTCZHmp38
Ni0Fx80Z8t91CzEsdhEuWg6das1yJSAN/ubjAynO9gIGaTLe66LyrwCFzSz4Wju/
2xgwg8gyUKcKZ5Iawda86gMN9f26Ks+YOfzeWmXJ48/bSHQHjtei6R6YHlTGHB7p
68glLd8yD7MOWYq7nRE6SQT2FFX/yD+/hYBMFaVo54/zFH7P2F94p2kExIQS6Xy0
9F8FtoY54l2X8NTO+E1f13oWYaJbcC8KDn3PSwR/n3bfsJhq5JIhza4qnr302niU
cEpWHzaArszi6s6vd+5vvb7ICgYx/n8xhwPQvEhOiEeBfBRK7CsIO0s+M3th3Kgx
ixJP/6RTIqQ3BkBsEA3N7WzQ9VOO6/tNpM1b7Vk6k9aY7CS9nSs+mc6eo2Cvf7it
zG/m72GwJrtG+T1OfdKhoeezfjfeABaGvBvg3dPHEcAkiV9PBZpdssknYA3267uu
p4bxThryoTyXXOyX+ycUB3YZ2xq+AxxBiDHDjTmzDFSPzZ9tZ8RwXUh0W2X3xzUe
UK4ZfPGEKJXKSGkklAtWxaHsO9CnjA0t7RVRby/jXYev1ih3IOfjaQNHW+3KFd25
5d0CTDVxwynDPntu8wkPAUkQvyylvMXPRvzbcveomUxeLnmFBK0=
=wKJM
-----END PGP SIGNATURE-----

--0z5c7mBtSy1wdr4F--
