From: Leon Romanovsky <leon-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: Re: [PATCH v2 net-next 3/4] qed: Fix maximum number of CQs for iWARP
Date: Sun, 24 Sep 2017 13:35:54 +0300
Message-ID: <20170924103554.GC25094@mtr-leonro.local>
References: <1506244185-2129-1-git-send-email-Michal.Kalderon@cavium.com>
 <1506244185-2129-4-git-send-email-Michal.Kalderon@cavium.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
        protocol="application/pgp-signature"; boundary="wxDdMuZNg1r63Hyj"
Cc: davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org,
        Ariel Elior <Ariel.Elior-YGCgFSpz5w/QT0dZR+AlfA@public.gmane.org>
To: Michal Kalderon <Michal.Kalderon-YGCgFSpz5w/QT0dZR+AlfA@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1506244185-2129-4-git-send-email-Michal.Kalderon-YGCgFSpz5w/QT0dZR+AlfA@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org


--wxDdMuZNg1r63Hyj
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

On Sun, Sep 24, 2017 at 12:09:44PM +0300, Michal Kalderon wrote:
> The maximum number of CQs supported is bound to the number
> of connections supported, which differs between RoCE and iWARP.
>
> This fixes a crash that occurred in iWARP when running 1000 sessions
> using perftest.
>
> Fixes: 67b40dccc45 ("qed: Implement iWARP initialization, teardown and qp operations")
>
> Signed-off-by: Michal Kalderon <Michal.Kalderon-YGCgFSpz5w/QT0dZR+AlfA@public.gmane.org>
> Signed-off-by: Ariel Elior <Ariel.Elior-YGCgFSpz5w/QT0dZR+AlfA@public.gmane.org>
> ---
>  drivers/net/ethernet/qlogic/qed/qed_rdma.c | 12 ++++++------
>  1 file changed, 6 insertions(+), 6 deletions(-)
>

Thanks,
Reviewed-by: Leon Romanovsky <leonro-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>

--wxDdMuZNg1r63Hyj
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIzBAEBCAAdFiEEkhr/r4Op1/04yqaB5GN7iDZyWKcFAlnHiooACgkQ5GN7iDZy
WKfJAw//dk9MdhtytGYdJdYcYb50N98UoOmsOjCNdphkLK9eHASx/P4Qrd6t9ar0
77ZCcVF0w4R8/nEFKDcH1JQw0JfcIXf+UXRmnhs4DeiUpEItANMOx6uAfCau0tr9
khWF0riw+Ra8XX2o0FO0BQ/areOS+qRFnqNIlTvWQewZnoeR7DmUi8OuCu0ScQ/k
x1KTyZEOLyfKZm2FMcsLzaUU8D7POQ/ksjCMm6oxggP7YLB4yrKqptaLLplPlUHg
UYDsb1mEhyxutOZ5AlIb+SCf2wQZ45Vnvi0i7zcvgSxGw1+4SPpsLA5RALp0aQwv
jv13GLn3qO0xMOTRZHvkH9Ow/m/Szyh181PIjjGXnDWjXzTR3nkUyaksjxyn6btp
y+ljuKTwGsJyT2eK4Sx6MWTqk7hkRXFsX+M3qHzE+tkyxRc6wyzPY8exr+W8Xb8p
ISDZJLO9wWfgQRAabf4NwHg8JNfBa3HLUl9u6krjTZkyhM335u59So8D2PwQPf0X
fCII6N9J7eNYQhJa+/Ki/yidzzIw3onc387k5QOuuQ/dkY/09ATXVI1yZ0zGNEeG
99ctV1Jt29tc4Pj3q5u27lE0CoKAi+eUvUtnCN2fUjHm4Xm4V+i9n+VT/cjceQ12
ipSo+J0t01kMENlEppOpWyf0Wz1b1gf/HcpbLSCNzy42I5HnYDg=
=rs7P
-----END PGP SIGNATURE-----

--wxDdMuZNg1r63Hyj--
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
