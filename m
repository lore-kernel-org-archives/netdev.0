From: Leon Romanovsky <leon-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: Re: [PATCH net-next 4/4] mlx4: sizeof style usage
Date: Tue, 15 Aug 2017 21:13:24 +0300
Message-ID: <20170815181324.GA24282@mtr-leonro.local>
References: <20170815172919.26153-1-sthemmin@microsoft.com>
 <20170815172919.26153-5-sthemmin@microsoft.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
        protocol="application/pgp-signature"; boundary="6AFz5yWxU/FsGPwt"
Cc: mlindner-eYqpPyKDWXRBDgjK7y7TUQ@public.gmane.org, mst-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, jasowang-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org,
        netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        virtualization-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org,
        Stephen Hemminger <sthemmin-0li6OtcxBFHby3iVrkZq2A@public.gmane.org>
To: Stephen Hemminger <stephen-OTpzqLSitTUnbdJkjeBofR2eb7JE58TQ@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20170815172919.26153-5-sthemmin-0li6OtcxBFHby3iVrkZq2A@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org


--6AFz5yWxU/FsGPwt
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

On Tue, Aug 15, 2017 at 10:29:19AM -0700, Stephen Hemminger wrote:
> The kernel coding style is to treat sizeof as a function
> (ie. with parenthesis) not as an operator.
>
> Also use kcalloc and kmalloc_array
>
> Signed-off-by: Stephen Hemminger <stephen-OTpzqLSitTUnbdJkjeBofR2eb7JE58TQ@public.gmane.org>
> ---
>  drivers/net/ethernet/mellanox/mlx4/alloc.c         |  2 +-
>  drivers/net/ethernet/mellanox/mlx4/cmd.c           |  4 ++--
>  drivers/net/ethernet/mellanox/mlx4/en_resources.c  |  2 +-
>  drivers/net/ethernet/mellanox/mlx4/en_rx.c         |  2 +-
>  drivers/net/ethernet/mellanox/mlx4/en_tx.c         |  2 +-
>  drivers/net/ethernet/mellanox/mlx4/eq.c            | 20 +++++++++---------
>  drivers/net/ethernet/mellanox/mlx4/fw.c            |  2 +-
>  drivers/net/ethernet/mellanox/mlx4/icm.c           |  2 +-
>  drivers/net/ethernet/mellanox/mlx4/icm.h           |  4 ++--
>  drivers/net/ethernet/mellanox/mlx4/intf.c          |  2 +-
>  drivers/net/ethernet/mellanox/mlx4/main.c          | 12 +++++------
>  drivers/net/ethernet/mellanox/mlx4/mcg.c           | 12 +++++------
>  drivers/net/ethernet/mellanox/mlx4/mr.c            | 10 ++++-----
>  drivers/net/ethernet/mellanox/mlx4/qp.c            | 12 +++++------
>  .../net/ethernet/mellanox/mlx4/resource_tracker.c  | 24 +++++++++++-----------
>  15 files changed, 56 insertions(+), 56 deletions(-)
>

Thanks,
Reviewed-by: Leon Romanovsky <leonro-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>

--6AFz5yWxU/FsGPwt
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIzBAEBCAAdFiEEkhr/r4Op1/04yqaB5GN7iDZyWKcFAlmTOcQACgkQ5GN7iDZy
WKcUkxAAz34nMe12aEOReWgbjD5GC6MemcYdOgD3OhleoL0z119szmT/SkmH1h0b
gsImVbDMXD2ejKmGRRDf8GeuKPhK5NfXuEHrkH4o7mNIvvyO6gkPlIoX0VVCzqEK
/obxjH8szbtITVVwoHJMvusJUM7uHD0/ueoUJONbFoDsXG8zlVUnIouMA+rPJl0Q
pSLTR02Aw5kKqntEN+uGRWjwOIUDpoDrLi+0HPY6LqLeWGUqiO6qA+fBIF4Pa4SZ
Ms2okJkomotNGpJ2Uda4NU2P3mWWp2KVQTqcwjHTY1f9bBnx+gOAvUZiJRglFk0N
vFmjQqqCwz0kv1mYFt6uh9ayLhFmtbq124bYfOA1jEoeMhDwaPQ6kv6uYgwpjalE
y1WqkZVrN8JSDAQfE6n6LDPIQ5IBP6P0f4gD0UXMxWkX/i91Noe7eYe2gYLqo71Z
CtRiMQ+Ubtwk4oWPlv59XYdB6Y1fOfNUePcEMAKbZ68MWenlFxKFErgV/Z7MFvy5
Yv8uadwjwmZ3CJ2rLCSMmp3wWZ0TsDhHkSGs5TEF8HCQgl2qKOgHUFNyTQ//Ur8I
Y5dpdMJ5VxlxF/07RUMSOXORPxDYVlMreTuL72ywes5oqRd6yOvfqj0QiR2rd5a7
VxfGbNNoC7pyegRzZ7Q7aLExICCHO3VelrVsN7zXUBX0X3PGGvU=
=SFz8
-----END PGP SIGNATURE-----

--6AFz5yWxU/FsGPwt--
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
