From: Leon Romanovsky <leonro-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
Subject: Re: [PATCH] mellanox: mlx5: Use logging functions to reduce text
 ~10k/5%
Date: Thu, 23 Jun 2016 08:27:01 +0300
Message-ID: <20160623052701.GB30933@leon.nu>
References: <1466619839.13093.4.camel@perches.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="xgyAXRrhYN0wYx8y"
Cc: Matan Barak <matanb-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>, <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	<linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	linux-kernel <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Saeed Mahameed <saeedm-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>, Joe Perches <joe-6d6DIl74uiNBDgjK7y7TUQ@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1466619839.13093.4.camel-6d6DIl74uiNBDgjK7y7TUQ@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

--xgyAXRrhYN0wYx8y
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Wed, Jun 22, 2016 at 11:23:59AM -0700, Joe Perches wrote:
> The logging macros create a bit of duplicated code/text.
>=20
> Use specialized functions to reduce the duplication.
>=20
> (defconfig/x86-64)
> $ size drivers/net/ethernet/mellanox/mlx5/core/built-in.o*
> =A0=A0=A0text	=A0=A0=A0data	=A0=A0=A0=A0bss	=A0=A0=A0=A0dec	=A0=A0=A0=A0h=
ex	filename
> =A0178634	=A0=A0=A02059	=A0=A0=A0=A0=A016	=A0180709	=A0=A02c1e5	drivers/n=
et/ethernet/mellanox/mlx5/core/built-in.o.new
> =A0188679	=A0=A0=A02059	=A0=A0=A0=A0=A016	=A0190754	=A0=A02e922	drivers/n=
et/ethernet/mellanox/mlx5/core/built-in.o.old
>=20
> The output changes now do not include line #,
> but do include the function offset.
>=20
> Signed-off-by: Joe Perches <joe-6d6DIl74uiNBDgjK7y7TUQ@public.gmane.org>

As far as I see all these functions are used in error paths, so no
implication on performance is expected.

And I'm fine with function offsets.

Saeed,
What do you think?

Reviewed-by: Leon Romanovsky <leonro-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>

--xgyAXRrhYN0wYx8y
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIcBAEBAgAGBQJXa3MlAAoJEORje4g2clincPIP/00hmu0VdtvzuFc/N8mYISVr
LD2HYxKcqqa4Z1ARBrx/JS/37DFwIgKs1VIsQ58P8Ckb+oIwfSH/slLrXVdVtqDS
mOR9WXTjHuwLKIlvaNp8+8LTA83pjKyQBSZoWzRUr600TK7OPV7TUkx5cMdjPc3r
sksPSKIWYR30mIrEI5zfp35WaBucmaSZpb3EHJvuJwF3gFvE3Zm+gIlRHFEk+fv8
dxkNrNfBzOO6bkv8Os1j1tyMeGoLsmdFgrxMRUbu23YQwTTmkPj9EQVNu6ZrOVRs
OHxChcql+nkleUh7X8WP/2hBXcy3PgTND5pHTUaBurJCymweAApoY0l0y6JoHJjL
GKtiCvf0410UwE741+1x92XphJQAIJP7K+02amd+zO5u3JZW08x1go07GpKGIZh4
oOY51Aqy77Z8T7De+sMG0uKAaSYi+gX7Iz8yR0bhsmwZGTUS8ecHQW9u/OZyrhxm
gPwLg/ZVCREbYs2Xkt6O5ymgoiV6NCw5jrD1LGGK3huDwwKcwqEkZmhSju6q+krL
XHluelhO0TTtgVPYn58viKrRK4oy/K3gOijomEIYZmJHaElGrd9HWB+9d2WY69uE
0VLCW/porVyIVddyhm8RMCYVHELlCT6yLNrPgTr+INC7ULFixuLxoZKOXn+dIPWI
LMCq3H5TWx25NleIHB1f
=xIYj
-----END PGP SIGNATURE-----

--xgyAXRrhYN0wYx8y--
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
