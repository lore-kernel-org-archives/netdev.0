From: Leon Romanovsky <leon-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: Re: [PATCH net-next 3/4] qed: Fix maximum number of CQs for iWARP
Date: Tue, 19 Sep 2017 20:46:10 +0300
Message-ID: <20170919174610.GK5788@mtr-leonro.local>
References: <1505841979-26365-1-git-send-email-Michal.Kalderon@cavium.com>
 <1505841979-26365-4-git-send-email-Michal.Kalderon@cavium.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
        protocol="application/pgp-signature"; boundary="Ah9ph+G2cWRpKogL"
Cc: davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org,
        Ariel Elior <Ariel.Elior-YGCgFSpz5w/QT0dZR+AlfA@public.gmane.org>
To: Michal Kalderon <Michal.Kalderon-YGCgFSpz5w/QT0dZR+AlfA@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1505841979-26365-4-git-send-email-Michal.Kalderon-YGCgFSpz5w/QT0dZR+AlfA@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org


--Ah9ph+G2cWRpKogL
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

On Tue, Sep 19, 2017 at 08:26:18PM +0300, Michal Kalderon wrote:
> The maximum number of CQs supported is bound to the number
> of connections supported, which differs between RoCE and iWARP.
>
> This fixes a crash that occurred in iWARP when running 1000 sessions
> using perftest.
>
> Signed-off-by: Michal Kalderon <Michal.Kalderon-YGCgFSpz5w/QT0dZR+AlfA@public.gmane.org>
> Signed-off-by: Ariel Elior <Ariel.Elior-YGCgFSpz5w/QT0dZR+AlfA@public.gmane.org>
> ---

It is worth to add Fixes line.

Thanks

--Ah9ph+G2cWRpKogL
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIzBAEBCAAdFiEEkhr/r4Op1/04yqaB5GN7iDZyWKcFAlnBV+IACgkQ5GN7iDZy
WKdiZhAAmnyGLWOBbkXCcjc01/Z868WLbhIZYZaa+Z3WjK3hdwCtvkxT6lH1tfHw
ZyELdn/on13j7wfwnnkQXe6jfOmS7a+B3X2WJE+/lmeSZUKZ2EolNadCnwOYkdWW
a65AwgEFfadMiAksEGM8BXflyFDMMwimcgdg1qhW4O8YEwRpM8ehjmWE7GS/RSjv
fyYZb6LKl7aZcMRXniTy7wfW+ba5+DaKSgPWllcdG4HOoFQcj3LMPzOLJmjpnCup
sGCegALOqmW+uzIE8184D7AZBnYblfAmqzZ/s8hbcZZNCbWvddZbYaibgIAgkxsk
9dGqhc6EU2ZJbLWnkIn8J9WKpnDlTC9d5z61OxuIdFn5UJWFfrifUzqUIY5YY9l+
jOhUfGAsSICM8CISVP3zJWHNL/yoETQzrrQ9negEQcI9fKmus+RlrOgrhmQHnrlt
wSYp3WfgTqkTb+KR8C61rRnPXjiRiK8tyhuWn1f5tvCTCfkf8dcQzbHkuCCNrs+B
UkJ4RL+q12imo9m1xvGrKtMNlu1eT2nRV2aN9OLX1XZq5SqEBZ9ENjjXtqlUQUdU
KoTKYBY4xBOnz/I42+pCKxmry4tkZCzpMjR7hVBt2Nw18Sl9KBgRATscTl6Ef5hA
rmqVqw5nLjRY2I/38nXjknL54tW21ehRvZy8mJkBFPZngcveahQ=
=cZF9
-----END PGP SIGNATURE-----

--Ah9ph+G2cWRpKogL--
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
