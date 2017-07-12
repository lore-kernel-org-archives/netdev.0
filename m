From: Leon Romanovsky <leon-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: Re: [PATCH 1/1] mlx4_en: remove unnecessary returned value check
Date: Wed, 12 Jul 2017 12:46:18 +0300
Message-ID: <20170712094618.GC1528@mtr-leonro.local>
References: <1499841873-10275-1-git-send-email-yanjun.zhu@oracle.com>
 <20170712083647.GB2866@yuvallap>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
        protocol="application/pgp-signature"; boundary="XPfPv5HFi+O4rHSw"
Cc: Zhu Yanjun <yanjun.zhu-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>, tariqt-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org,
        netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Yuval Shaia <yuval.shaia-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20170712083647.GB2866@yuvallap>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org


--XPfPv5HFi+O4rHSw
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

On Wed, Jul 12, 2017 at 11:36:48AM +0300, Yuval Shaia wrote:
> On Wed, Jul 12, 2017 at 02:44:33AM -0400, Zhu Yanjun wrote:
> > The function __mlx4_zone_remove_one_entry always returns zero. So
> > it is not necessary to check it.
> >
> > Cc: Joe Jin <joe.jin-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>
> > Cc: Junxiao Bi <junxiao.bi-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>
> > Signed-off-by: Zhu Yanjun <yanjun.zhu-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>
> > ---
> >  drivers/net/ethernet/mellanox/mlx4/alloc.c | 7 +++----
> >  1 file changed, 3 insertions(+), 4 deletions(-)
> >
> > diff --git a/drivers/net/ethernet/mellanox/mlx4/alloc.c b/drivers/net/ethernet/mellanox/mlx4/alloc.c
> > index 249a458..bfb185d 100644
> > --- a/drivers/net/ethernet/mellanox/mlx4/alloc.c
> > +++ b/drivers/net/ethernet/mellanox/mlx4/alloc.c
> > @@ -283,7 +283,7 @@ int mlx4_zone_add_one(struct mlx4_zone_allocator *zone_alloc,
> >  }
> >
> >  /* Should be called under a lock */
> > -static int __mlx4_zone_remove_one_entry(struct mlx4_zone_entry *entry)
> > +static void __mlx4_zone_remove_one_entry(struct mlx4_zone_entry *entry)
> >  {
> >  	struct mlx4_zone_allocator *zone_alloc = entry->allocator;
> >
> > @@ -315,8 +315,6 @@ static int __mlx4_zone_remove_one_entry(struct mlx4_zone_entry *entry)
> >  		}
> >  		zone_alloc->mask = mask;
> >  	}
> > -
> > -	return 0;
> >  }
> >
> >  void mlx4_zone_allocator_destroy(struct mlx4_zone_allocator *zone_alloc)
> > @@ -468,7 +466,8 @@ int mlx4_zone_remove_one(struct mlx4_zone_allocator *zones, u32 uid)
> >  		goto out;
> >  	}
> >
> > -	res = __mlx4_zone_remove_one_entry(zone);
> > +	__mlx4_zone_remove_one_entry(zone);
> > +	res = 0;
>
> Will look better if initialization will move to variable declaration.
>

Yes, please.

Thanks

--XPfPv5HFi+O4rHSw
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIzBAEBCAAdFiEEkhr/r4Op1/04yqaB5GN7iDZyWKcFAlll7+oACgkQ5GN7iDZy
WKdx/A//fqipJUBVk+pREJMGJd1LqH9pr6mkXXpi/MZEMUWB75eVqsvo2bfXixvI
YVh8oExpwMQFo0I5s5jK9tzCvuJYSEqedwRD0tTnRubUOl/WT3BcEi1aajMLHtEz
71wqlXMITymC4HhgJswGTOxF/X3he9Z6wKcXImTbcIl/67zR208EYLL4BAyhMukX
6mMJ54nMtumeEkUXSCWtXYcv+xST1HUUDW/NRH9fJo5OSrfSGl3XcMQfP7NeBNVP
6yfCbXMNW6tFNHQGLA50ZePvGOCHKFdYoJYfMU9gUlJVBRDRoG16oZnTkq3Dr0p1
mad7M88XX0N/8Xoe4+ffIL2/ixUi35IbFTYq/agOo3hsGuxhky4FjctE57Fxuq4M
JcIwzx1lcUQUDCPhljGbrfJR98OLwZIangzGuDP6jBSoFrKB/4u98hQ1aPubz3ap
cqMV9rvppZk6HlyG5VxWODf8t13/6gCB5WtmmTEUcVhG5s2mgcaKNW+ia0xMN0Zf
FlyPOw7Awyd/eL28MtJ6Y7YTyhTZhMirqehEIgyluCY/DPBbclj82MQNdNiyj9fj
Efpgo+AedwJWrwb4WpA7FxXgmqsyMupKhjepCEdk6i2e25TutftQf3pTYp5vK8HG
5QarAeVGpKQgKcApaC33UvK7sVLbS25GUBWvf1g8CjCf622mW8w=
=7ayR
-----END PGP SIGNATURE-----

--XPfPv5HFi+O4rHSw--
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
