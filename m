From: Leon Romanovsky <leonro-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
Subject: Re: [patch v2] net/mlx5: missing error code in
 esw_create_offloads_fdb_table()
Date: Wed, 13 Jul 2016 16:04:59 +0300
Message-ID: <20160713130459.GF10079@leon.nu>
References: <83d5a5bb-dbf5-6c8f-39ea-320d55026a9d@mellanox.com>
 <20160713100825.GD29468@mwanda>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="i3lJ51RuaGWuFYNw"
Cc: Matan Barak <matanb-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	Or Gerlitz <ogerlitz-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>, <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	<linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, <kernel-janitors-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Dan Carpenter <dan.carpenter-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20160713100825.GD29468@mwanda>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

--i3lJ51RuaGWuFYNw
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Wed, Jul 13, 2016 at 02:48:44PM +0300, Dan Carpenter wrote:
> We accidentally return success when we had intended to return an error
> code.
>=20
> Fixes: 69697b6e2086 ('net/mlx5: E-Switch, Add support for the sriov offlo=
ads mode')
> Signed-off-by: Dan Carpenter <dan.carpenter-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>
> ---
> v2: return -ENOTSUPP instead --EINVAL

I'm a little bit confused. Why did you prefer ENOTSUPP over EOPNOTSUPP?

Thanks.

--i3lJ51RuaGWuFYNw
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIcBAEBAgAGBQJXhjx6AAoJEORje4g2clinGqcQAKGkCXG61tY3QnItlxxRxTbH
U9hwfs+Rh8GhFRfV/tQXQfpBXqtUFzl+ZFGFXYqn2rD4jTf0TIsJ5G0EiZ35g8Gq
QJbdpkoLSKdYX3ywzxWFESg14IRgyYtFYza3dddD8tR5gwo6QDj+L8qJx3CY4Osd
PQVSorCBc3IPsPKxf3G1KYTWRGbq9JI6ml8TZWoAojmb8BXHcRQndyMtfV3EcgPC
Q1028HkODG932Ux5KrxBPRPo5tuvd8Nvto384eKxJ01Go7OpNlsFiQD2Mn0WKnLr
aMD3HQvHUxTF4nO1M6ubMVspkzB854o0syneoKgS+WvxhwkJqFlTYOkGiReN76To
oXwNWZUQlpgJMJ8Xwz2jD+1EQ023UI91y6A/SXt7K9VY5hhSwGDQFERtAqiSJfif
6jbLBNKwlMzvQBwMuvBjfRz4sg9I9rOr42igGJnvwm3xgZjg52NFj4yEmltAhQzK
UO/uNYRntlKihol+hhA0tuL7x3eR+2VMza7HlHNdl+a6HCG336/1/cGoszeS8Q5X
sXZyw+9sWPydGe54T5kxDm3lH51XLj/enLj5P/QFHAZ7TOucICHPRIJj/Y4PP8cJ
yevKWTS8y1Me/D80PsmA1ifqwZAjFEpLz9BicTGfD58co7/0XHbsWC+HQxvnu5+Z
d04eU4BqpAcC9Dnf8Aag
=QilC
-----END PGP SIGNATURE-----

--i3lJ51RuaGWuFYNw--
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
