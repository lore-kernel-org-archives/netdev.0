From: "Dmitry V. Levin" <ldv@altlinux.org>
Subject: Re: [PATCH v06 35/36] uapi linux/tls.h: don't include <net/tcp.h> in
 user space
Date: Wed, 9 Aug 2017 02:25:54 +0300
Message-ID: <20170808232554.GK10552@altlinux.org>
References: <20170806164428.2273-1-mikko.rapeli@iki.fi>
 <20170806164428.2273-36-mikko.rapeli@iki.fi>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
        protocol="application/pgp-signature"; boundary="OOq1TgGhe8eTwFBO"
Cc: linux-kernel@vger.kernel.org, linux-api@vger.kernel.org,
        Dave Watson <davejwatson@fb.com>,
        Ilya Lesokhin <ilyal@mellanox.com>,
        Aviad Yehezkel <aviadye@mellanox.com>, netdev@vger.kernel.org
To: Mikko Rapeli <mikko.rapeli@iki.fi>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20170806164428.2273-36-mikko.rapeli@iki.fi>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--OOq1TgGhe8eTwFBO
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Sun, Aug 06, 2017 at 06:44:26PM +0200, Mikko Rapeli wrote:
> It is not needed and not part of uapi headers, but causes
> user space compilation error:
>=20
> fatal error: net/tcp.h: No such file or directory
>  #include <net/tcp.h>
>                      ^
>=20
> Signed-off-by: Mikko Rapeli <mikko.rapeli@iki.fi>
> Cc: Dave Watson <davejwatson@fb.com>
> Cc: Ilya Lesokhin <ilyal@mellanox.com>
> Cc: Aviad Yehezkel <aviadye@mellanox.com>
> ---
>  include/uapi/linux/tls.h | 2 ++
>  1 file changed, 2 insertions(+)
>=20
> diff --git a/include/uapi/linux/tls.h b/include/uapi/linux/tls.h
> index cc1d21db35d8..d87c698623f2 100644
> --- a/include/uapi/linux/tls.h
> +++ b/include/uapi/linux/tls.h
> @@ -37,7 +37,9 @@
>  #include <asm/byteorder.h>
>  #include <linux/socket.h>
>  #include <linux/tcp.h>
> +#ifdef __KERNEL__
>  #include <net/tcp.h>
> +#endif

Let's move it to include/net/tls.h instead.


--=20
ldv

--OOq1TgGhe8eTwFBO
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIcBAEBCAAGBQJZikiCAAoJEAVFT+BVnCUI5CIP/RKMUsBCyslmX84MBNevDBFa
UuI9698oybrdw0v0fjhmsMLH5VgvBu8gbQmkB7pyATw7ndRZP2cp5bHDSLsafJNv
PklNqZjEfjhGC9CGpmKfhLhhiErBt2xlgyfNa/fFrOu//wVgb7kf4r+kj/cCAeKt
nllTm2GTtEpiUg/3nfnl3Da0TSz82ae15WRMyQ9/Crodwx8i3x21vAo139/rQm6m
kBCftX1lBRefZ+YCemL79Rr54TgBXmiy8qKKqxo5Kyw2sSmwH+nT1eER5ZKCijRB
6WQV5pHEIplyakhIIA02ctbZ7XCFFC7wAJ0Gj8gc2InT5SbpXt/5As79tcTJW6tx
njy8m1Jg3StfQ0HLUQynYN+aG07dnvHphoV2ZdHNJyTRbdroOCy5oLWE0ZTkEP0L
G4TbGJ8gLJ730pPxCabWR/zhx7sZsG7lUzvhaSfZ65Inc1HJAyCwWayH2UfDOATS
8/y5BgJMqV2s3JiEFKPAv9UvxUb2Auu++hu1fEZ9tjI9yVbdZp5lonZzVTb/qcNo
etfG7xAJinv2CSxmoVnsVX5nPqdsU09vq/MA5kpAvtcLSrPo7BB2VWR3apdS83Ua
E/xwXUzqX57EK8xC6h4XGdBnz2nKuRCPeb0fEGUx05mcBgPYneP5JBBp+Zl0kkkq
6+Iso63/8SKt9mcPTA/0
=Twx0
-----END PGP SIGNATURE-----

--OOq1TgGhe8eTwFBO--
