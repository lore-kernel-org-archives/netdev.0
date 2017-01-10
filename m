From: Leon Romanovsky <leonro-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
Subject: Re: [for-next V3 00/10][pull request] Mellanox 100G mlx5 4K UAR
 support
Date: Tue, 10 Jan 2017 08:50:08 +0200
Message-ID: <20170110065008.GG7218@mtr-leonro.local>
References: <1483988453-28551-1-git-send-email-saeedm@mellanox.com>
 <1484024006.2149.11.camel@redhat.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
        protocol="application/pgp-signature"; boundary="s9fJI615cBHmzTOP"
Cc: Saeed Mahameed <saeedm-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
        "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>, <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        <linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Eli Cohen <eli-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
        Matan Barak <matanb-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
To: Doug Ledford <dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1484024006.2149.11.camel-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

--s9fJI615cBHmzTOP
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Mon, Jan 09, 2017 at 11:53:26PM -0500, Doug Ledford wrote:
> On Mon, 2017-01-09 at 21:00 +0200, Saeed Mahameed wrote:
> > Hi Dave and Doug,
> >
> > Following the mlx5-odp submission, you can find here the 2nd mlx5
> > submission for 4.11 as a pull-request including mlx5 4K UAR support
> > from
> > Eli Cohen (details below).=A0=A0For you Doug, this pull request will
> > provide
> > you with both mlx5 odp and mlx5 4k UAR since it is based on Dave's
> > net-next mlx5-odp merge commit.
> >
> > v1->v2:
> > =A0 - Removed 64BIT arch dependency.
> > v2->v3:
> > =A0 - Removed extra space.
> >
> > Thank you,
> > Saeed.
> >
> > The following changes since commit
> > 525dfa2cdce4f5ab76251b5e57ebabf4f2dfc40c:
> >
> > =A0 Merge branch 'mlx5-odp' (2017-01-02 15:51:21 -0500)
>
> This base commit looks harmless enough, but since it's likely just a
> commit in your tree, it isn't really a clear indicator of how you set
> this tree up....
>
> > are available in the git repository at:
> >
> > =A0 git://git.kernel.org/pub/scm/linux/kernel/git/mellanox/linux.git
> > tags/mlx5-4kuar-for-4.11
> >
> > for you to fetch changes up to
> > f502d834950a28e02651bb7e2cc7111ddd352644:
> >
> > =A0 net/mlx5: Activate support for 4K UARs (2017-01-09 20:25:10 +0200)
>
> But once I pulled this, it became clear you guys based your tree on a
> net-next starting point. =A0You need to make that clear in the beginning.
> =A0And unless you can't avoid it, don't do it. =A0I don't like having to
> pull in Dave's net-next before I pull your code because it means I
> can't submit my pull request to Linus during the merge window as a
> single pull request, I have to split it up to be the stuff that is
> based on net-next and the stuff based on my own next area.
>
> >=A0
> > ----------------------------------------------------------------
> > Eli Cohen (10):
> > =A0=A0=A0=A0=A0=A0IB/mlx5: Fix kernel to user leak prevention logic
> > =A0=A0=A0=A0=A0=A0IB/mlx5: Fix error handling order in create_kernel_qp
> > =A0=A0=A0=A0=A0=A0mlx5: Fix naming convention with respect to UARs
> > =A0=A0=A0=A0=A0=A0IB/mlx5: Fix retrieval of index to first hi class bfr=
eg
> > =A0=A0=A0=A0=A0=A0net/mlx5: Introduce blue flame register allocator
> > =A0=A0=A0=A0=A0=A0net/mlx5: Add interface to get reference to a UAR
> > =A0=A0=A0=A0=A0=A0IB/mlx5: Use blue flame register allocator in mlx5_ib
> > =A0=A0=A0=A0=A0=A0IB/mlx5: Allow future extension of libmlx5 input data
> > =A0=A0=A0=A0=A0=A0IB/mlx5: Support 4k UAR for libmlx5
> > =A0=A0=A0=A0=A0=A0net/mlx5: Activate support for 4K UARs
> >
> > =A0drivers/infiniband/hw/mlx5/cq.c=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=
=A0=A0=A0=A0=A0=A0=A0=A0|=A0=A010 +-
> > =A0drivers/infiniband/hw/mlx5/main.c=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=
=A0=A0=A0=A0=A0=A0=A0| 278 ++++++++++-
> > -----
> > =A0drivers/infiniband/hw/mlx5/mlx5_ib.h=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=
=A0=A0=A0=A0=A0|=A0=A032 +-
> > =A0drivers/infiniband/hw/mlx5/qp.c=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=
=A0=A0=A0=A0=A0=A0=A0=A0| 290 +++++++--
> > --------
> > =A0drivers/net/ethernet/mellanox/mlx5/core/cq.c=A0=A0=A0=A0=A0=A0=A0|=
=A0=A0=A02 +
> > =A0drivers/net/ethernet/mellanox/mlx5/core/en.h=A0=A0=A0=A0=A0=A0=A0|=
=A0=A011 +-
> > =A0.../net/ethernet/mellanox/mlx5/core/en_common.c=A0=A0=A0=A0|=A0=A012=
 +-
> > =A0drivers/net/ethernet/mellanox/mlx5/core/en_main.c=A0=A0|=A0=A021 +-
> > =A0drivers/net/ethernet/mellanox/mlx5/core/eq.c=A0=A0=A0=A0=A0=A0=A0|=
=A0=A014 +-
> > =A0drivers/net/ethernet/mellanox/mlx5/core/main.c=A0=A0=A0=A0=A0|=A0=A0=
26 +-
> > =A0drivers/net/ethernet/mellanox/mlx5/core/uar.c=A0=A0=A0=A0=A0=A0| 351
> > +++++++++++++--------
> > =A0include/linux/mlx5/cq.h=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=
=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0|=A0=A0=A05 +-
> > =A0include/linux/mlx5/device.h=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=
=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0|=A0=A023 +-
> > =A0include/linux/mlx5/doorbell.h=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=
=A0=A0=A0=A0=A0=A0=A0=A0=A0|=A0=A0=A06 +-
> > =A0include/linux/mlx5/driver.h=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=
=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0|=A0=A081 ++---
> > =A0include/linux/mlx5/mlx5_ifc.h=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=
=A0=A0=A0=A0=A0=A0=A0=A0=A0|=A0=A0=A07 +-
> > =A0include/uapi/rdma/mlx5-abi.h=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=
=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0|=A0=A019 +-
> > =A017 files changed, 672 insertions(+), 516 deletions(-)
>
> Without going into excruciating detail, this is what I got when I
> pulled your branch:
>
> =A0273 files changed, 8891 insertions(+), 6637 deletions(-)
> =A0create mode 100644 drivers/net/ethernet/qlogic/qede/qede_filter.c
> =A0create mode 100644 drivers/net/ethernet/qlogic/qede/qede_fp.c
>
> Please don't do this unless you absolutely have to.

We will do our best to avoid such situations in the future.

This specific pull request was after our mistake with first pull
request, which was sent as a patch set, instead of pull request.

>
> --
> Doug Ledford <dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
> =A0 =A0 GPG KeyID: B826A3330E572FDD
> =A0 =A0
> Key fingerprint =3D AE6B 1BDA 122B 23B4 265B =A01274 B826 A333 0E57 2FDD



--s9fJI615cBHmzTOP
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIzBAEBCAAdFiEEkhr/r4Op1/04yqaB5GN7iDZyWKcFAlh0hCAACgkQ5GN7iDZy
WKfndg//SeMWjN9ll4usE8gJm7WJr4yQ9mQKF5dXyYc6bpm525UxXrzMwxy2mha1
Mh9MoA7/quGzLCvoXJMt0Ns2Glt5wTIRvpRzTS/Kag8c52KaO5o5E4jp+VbfvaTG
WFGJtStIsE+anLjZj59tc8zYQ/je27OINf+Vv/hrSb4FPKnuQtrzZfA8bM8URSHN
KqXOiFO3RY5XiYcJ089G869xD75kbegJPO9rA6GJjA9RhWjnlqeSWFoDBoLyeLyh
OhEa8jg8uvWZM1hUyW3ufVHxgaioenTwz0gJS/8ZxiX7H1A6VMFKbvcwcAQc9tY1
DIv/FoMkQX9JTWwsu0Y2NlI/1qiDjbh9Eooe+QRTjLaqSx2+cHdZRzDGoaXue1n0
Wfdpc8W9ARFdYdcxtaSbqdMQlvRuoxZREmmahXDXcMTks2zFU6RIts9Y2FaTuINO
sDwNKwvUVoG3o0w2iXzENsFk0JYMiYqbGvnuulHNoQIhn6hqNKrcopqcVNVQhYfP
jl9dZGF55E+SIdaklULwAzz7THkXSYkf4FS301ztwpRTpLKckfRl8+A/ym5qMl5v
KmF7ryfKWUHg+LwluHcH109JxrFdY+k+J8H1Xs9jSFxJFGYBExwM1okaRq53YxAS
2MrIT/rDB23NExIyM+tZ96d4ogF8Vj/BBxmFm9GKou4xbwA+Qd8=
=dmJF
-----END PGP SIGNATURE-----

--s9fJI615cBHmzTOP--
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
