From: Leon Romanovsky <leonro@mellanox.com>
Subject: Re: [for-next 07/10] IB/mlx5: Use blue flame register allocator in
 mlx5_ib
Date: Sun, 8 Jan 2017 08:22:57 +0200
Message-ID: <20170108062257.GH15685@mtr-leonro.local>
References: <CAL3tnx4H2HsGMH=caiobivvvs0AU9yrzCmVONOdUQ_j_JMfufA@mail.gmail.com>
 <20170105.150731.2097384465565543422.davem@davemloft.net>
 <20170106060608.GG15685@mtr-leonro.local>
 <20170106.111131.1775665484264248231.davem@redhat.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
        protocol="application/pgp-signature"; boundary="WRT3RXLOp/bBMgTI"
Cc: <eli@dev.mellanox.co.il>, <saeedm@mellanox.com>,
        <dledford@redhat.com>, <netdev@vger.kernel.org>,
        <linux-rdma@vger.kernel.org>, <eli@mellanox.com>,
        <matanb@mellanox.com>
To: David Miller <davem@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ve1eur01on0066.outbound.protection.outlook.com ([104.47.1.66]:4485
        "EHLO EUR01-VE1-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1755783AbdAHGW6 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sun, 8 Jan 2017 01:22:58 -0500
Content-Disposition: inline
In-Reply-To: <20170106.111131.1775665484264248231.davem@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--WRT3RXLOp/bBMgTI
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

On Fri, Jan 06, 2017 at 11:11:31AM -0500, David Miller wrote:
> From: Leon Romanovsky <leonro@mellanox.com>
> Date: Fri, 6 Jan 2017 08:06:09 +0200
>
> > On Thu, Jan 05, 2017 at 03:07:31PM -0500, David Miller wrote:
> >> From: Eli Cohen <eli@dev.mellanox.co.il>
> >> Date: Thu, 5 Jan 2017 14:03:18 -0600
> >>
> >> > If necessary I can make sure it builds on 32 bits as well.
> >>
> >> Please do.
> >
> > Dave,
> >
> > I'm failing to understand the benefits of building mlx5 on 32 bits, and
> > see only disadvantages:
> >  * It is actual dead code without test coverage.
> >  * It misleads reviewers/customers by seeing code for 32 bits.
> >  * It adds compilation time for 32 bits platforms and "punishes" them
> >    for not relevant for them driver.
> >
> > Why do you call removing all that as a "regression"?
>
> We have this thing called "CONFIG_COMPILE_TEST", it has tons of value,
> perhaps you've seen it before?

Thanks David,
I see your point.

> --
> To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

--WRT3RXLOp/bBMgTI
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIzBAEBCAAdFiEEkhr/r4Op1/04yqaB5GN7iDZyWKcFAlhx2sEACgkQ5GN7iDZy
WKfCgg//SCfXHxn5DdUYaw72tDf5F/gW1Aw9wOMmLY4ljfU+Vj/pL0LzzCCkYo48
d6lL1NrZvy7Qbk5l+YCjjMcD3j8g8ZiRfFPbpFGb7Y9ICY6nBIuv7e5tbBbr7jtj
LJtIpUO50oI9Z+k4jDGgSrratpT4B6eBcGucZgIrnUeIExx/T/1J1u7gmIl8TK24
uUjuYkSd1o4dNtuQHVPCeqFCV+SvAskqkgQelid+ZOn5W8EWeVe2f8efWXjKRhKM
HtItEXOCxzQpbme5N56GSnMXAUCmZxLutpHGUW02Bd19f9N5U5WDjsOX0XcF907Z
zNOKjvLKT3JyilsdGrX7oa/G1m16mPxvaUTxyML1ElagMgmtAizEMNcwtp3MvVsM
ooZxwYR9LC/zyNtB4dtp9YZb8Q1ngZCVwFDWvF+xSvv7zzREr+NYjfxmNH+kVUfr
1EVFyThjTz6JQaJPWgm8/s6lkLxA2MGkcN//5oNhzUYm/U1VUwdJTNc5RAznvO32
ujzTsJhsN3jSsVeP8BQlK6nkAGdCBRPUP/h5x8sInU6DUshP1S6Q1bRSAWZyCm1f
68HGHkpi27bdJAx6c+BCI74wnswiTHLnW8gWYDpJapp31v+EVaeFKaZ4ENaIXJ63
MMcu/qbboPtWO+ksX9eWn0sksi/1nHU1G4lgB63EqHCjHyVsW/0=
=i2zK
-----END PGP SIGNATURE-----

--WRT3RXLOp/bBMgTI--
