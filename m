From: Leon Romanovsky <leonro@mellanox.com>
Subject: Re: [patch v2] net/mlx5: missing error code in
 esw_create_offloads_fdb_table()
Date: Thu, 14 Jul 2016 08:56:37 +0300
Message-ID: <20160714055637.GK10079@leon.nu>
References: <83d5a5bb-dbf5-6c8f-39ea-320d55026a9d@mellanox.com>
 <20160713100825.GD29468@mwanda>
 <20160713175454.GF19657@obsidianresearch.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="ZG5hGh9V5E9QzVHS"
Cc: Dan Carpenter <dan.carpenter@oracle.com>,
	Matan Barak <matanb@mellanox.com>,
	Or Gerlitz <ogerlitz@mellanox.com>, <netdev@vger.kernel.org>,
	<linux-rdma@vger.kernel.org>, <kernel-janitors@vger.kernel.org>
To: Jason Gunthorpe <jgunthorpe@obsidianresearch.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-db5eur01on0080.outbound.protection.outlook.com ([104.47.2.80]:25056
	"EHLO EUR01-DB5-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1750739AbcGNH30 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 14 Jul 2016 03:29:26 -0400
Content-Disposition: inline
In-Reply-To: <20160713175454.GF19657@obsidianresearch.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--ZG5hGh9V5E9QzVHS
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Wed, Jul 13, 2016 at 11:54:54AM -0600, Jason Gunthorpe wrote:
> On Wed, Jul 13, 2016 at 02:48:44PM +0300, Dan Carpenter wrote:
> > We accidentally return success when we had intended to return an error
> > code.
> >=20
> > Fixes: 69697b6e2086 ('net/mlx5: E-Switch, Add support for the sriov off=
loads mode')
> > Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>
> > v2: return -ENOTSUPP instead --EINVAL
> >=20
> > diff --git a/drivers/net/ethernet/mellanox/mlx5/core/eswitch_offloads.c=
 b/drivers/net/ethernet/mellanox/mlx5/core/eswitch_offloads.c
> > index 1842dfb..7d982cf 100644
> > +++ b/drivers/net/ethernet/mellanox/mlx5/core/eswitch_offloads.c
> > @@ -183,6 +183,7 @@ static int esw_create_offloads_fdb_table(struct mlx=
5_eswitch *esw, int nvports)
> > =20
> >  	root_ns =3D mlx5_get_flow_namespace(dev, MLX5_FLOW_NAMESPACE_FDB);
> >  	if (!root_ns) {
> > +		err =3D -ENOTSUPP;
>=20
> Did you mean ENOTSUP?
>=20
> I thought ENOTSUPP was not to be used outside NFS, and isn't properly
> exported to userspace..
>=20
> $ find /usr/include -name "*errno*" | xargs grep 524

I asked similar question [1] with different return value in reply
to this patch.

[1] http://marc.info/?l=3Dlinux-netdev&m=3D146843171508230&w=3D2

>=20
> Jason
> --
> To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

--ZG5hGh9V5E9QzVHS
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIcBAEBAgAGBQJXhymVAAoJEORje4g2clinr/kP/jlzDnz5hvIKtZXYGoBbsoHK
IY2H93jg9SL+4JGx+/AVn55Q2HJ3iJCfLIsHOeLqt5V9bslMb/b9B+Y3rlYyxBBM
fNLujlM3MYUgRIcoJg86tLFmm3cALCfxzsGZBlhbU/QzEDKsFcQe6zR0mjpx0GTO
Mo7s9vdQwL1wnoLI4+SWQP8y3QxG8OVWA6J2NgaamHBtn3zGGgsf8DDov5N1OoTz
S2HUHAn91rGollL+ow0D+n36df2fPPQ800Qb+APOey2tbzNCs9QvonkGDj3YAkeF
Avka4Gs1kmjphIP8ur7rvaSBVIuLA03gMGe0rKBtr9Je7Hj6OIPVyTOo0BvgMY/e
VlZQ/OchN7MF3qiUBA7xo7YHtlVBIeLjLuH9iEcbdGp04cxLJIuU+jZktTd0mIEV
3ABrwYracxEo46WKUjND9B0VY9m+TCg+r2UKaWeeuUnxEjarBQnEW2l4E0ga07Db
Tz9XuYKGmFkmLrpLcyIn6bhqva9ZGg8yz76aMFyPf7l7K2m6Zr9e7xZEFg/rJEvw
3xxx+IzsL6khTEG22Y37+zVUAiCsgr98XxUQSqk1NMdqRWbOKGIMallbPdCjpS9l
3CQdhWR2BTq8Kuatl/2e5WZAcibiCaHARkux1jV7GmH7KQQwjEXhv3a05d8EzDig
bBK+T8HMetW5AcOcGBIO
=/+TP
-----END PGP SIGNATURE-----

--ZG5hGh9V5E9QzVHS--
