From: Solomon Peachy <pizza@shaftnet.org>
Subject: Re: [PATCH 4/4] cw1200: hwio: Remove an unnecessary goto
Date: Tue, 4 Jun 2013 11:09:10 -0400
Message-ID: <20130604150910.GA13278@shaftnet.org>
References: <60123fd3175b7cceadf6c335b12e58b797e18f65.1370356776.git.joe@perches.com>
 <fd299c9ef87fe50c12af871d6bfcc92d7f6ef3dc.1370356776.git.joe@perches.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="gBBFr7Ir9EOA20Yy"
Cc: linux-kernel@vger.kernel.org,
	"John W. Linville" <linville@tuxdriver.com>,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org
To: Joe Perches <joe@perches.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <fd299c9ef87fe50c12af871d6bfcc92d7f6ef3dc.1370356776.git.joe@perches.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--gBBFr7Ir9EOA20Yy
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Tue, Jun 04, 2013 at 07:44:50AM -0700, Joe Perches wrote:
> goto after return is wrong.
>=20
> The other code in this block needs to set an
> error value then goto an error release block.
>=20
> This one doesn't need to release anything and
> was likely a copy/paste remainder.
>=20
> Signed-off-by: Joe Perches <joe@perches.com>

Acked-By: Solomon Peachy <pizza@shaftnet.org>

> ---
>  drivers/net/wireless/cw1200/hwio.c | 1 -
>  1 file changed, 1 deletion(-)
>=20
> diff --git a/drivers/net/wireless/cw1200/hwio.c b/drivers/net/wireless/cw=
1200/hwio.c
> index 142f45ef..dad3fb3 100644
> --- a/drivers/net/wireless/cw1200/hwio.c
> +++ b/drivers/net/wireless/cw1200/hwio.c
> @@ -178,7 +178,6 @@ int cw1200_indirect_read(struct cw1200_common *priv, =
u32 addr, void *buf,
>  	if ((buf_len / 2) >=3D 0x1000) {
>  		pr_err("Can't read more than 0xfff words.\n");
>  		return -EINVAL;
> -		goto out;
>  	}
> =20
>  	priv->hwbus_ops->lock(priv->hwbus_priv);
> --=20
> 1.8.1.2.459.gbcd45b4.dirty
>=20
> --
> To unsubscribe from this list: send the line "unsubscribe linux-wireless"=
 in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

--=20
Solomon Peachy        		       pizza at shaftnet dot org	=20
Delray Beach, FL                          ^^ (email/xmpp) ^^
Quidquid latine dictum sit, altum viditur.

--gBBFr7Ir9EOA20Yy
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.13 (GNU/Linux)

iD8DBQFRrgMWPuLgii2759ARAlkLAKC9y/w/jHAkjnhViOUZS6AG6Kc89ACgvlIB
tiLsCF7ClA23jyUZYw5ibjs=
=Zt6e
-----END PGP SIGNATURE-----

--gBBFr7Ir9EOA20Yy--
