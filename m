From: Antonio Quartulli <a@unstable.cc>
Subject: Re: [PATCH net-next 4/5] treewide: replace dev->trans_start update
 with helper
Date: Thu, 5 May 2016 01:20:42 +0800
Message-ID: <20160504172042.GH11201@prodigo.lan>
References: <1462285862-30946-1-git-send-email-fw@strlen.de>
 <1462285994-31983-1-git-send-email-fw@strlen.de>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
	protocol="application/pgp-signature"; boundary="hEk4XxIzAisM6naS"
Cc: netdev@vger.kernel.org,
	user-mode-linux-devel@lists.sourceforge.net,
	linux-xtensa@linux-xtensa.org,
	linux1394-devel@lists.sourceforge.net, linux-rdma@vger.kernel.org,
	MPT-FusionLinux.pdl@broadcom.com, linux-scsi@vger.kernel.org,
	linux-can@vger.kernel.org, linux-parisc@vger.kernel.org,
	linux-omap@vger.kernel.org, linux-hams@vger.kernel.org,
	linux-usb@vger.kernel.org, linux-wireless@vger.kernel.org,
	linux-s390@vger.kernel.org, devel@driverdev.osuosl.org,
	b.a.t.m.a.n@lists.open-mesh.org, linux-bluetooth@vger.kernel.org
To: Florian Westphal <fw@strlen.de>
Return-path: <linux-can-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1462285994-31983-1-git-send-email-fw@strlen.de>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--hEk4XxIzAisM6naS
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Tue, May 03, 2016 at 04:33:13PM +0200, Florian Westphal wrote:
> Replace all trans_start updates with netif_trans_update helper.
> change was done via spatch:
>=20
> struct net_device *d;
> @@
> - d->trans_start =3D jiffies
> + netif_trans_update(d)
>=20
> Compile tested only.
>=20
> Cc: user-mode-linux-devel@lists.sourceforge.net
> Cc: linux-xtensa@linux-xtensa.org
> Cc: linux1394-devel@lists.sourceforge.net
> Cc: linux-rdma@vger.kernel.org
> Cc: netdev@vger.kernel.org
> Cc: MPT-FusionLinux.pdl@broadcom.com
> Cc: linux-scsi@vger.kernel.org
> Cc: linux-can@vger.kernel.org
> Cc: linux-parisc@vger.kernel.org
> Cc: linux-omap@vger.kernel.org
> Cc: linux-hams@vger.kernel.org
> Cc: linux-usb@vger.kernel.org
> Cc: linux-wireless@vger.kernel.org
> Cc: linux-s390@vger.kernel.org
> Cc: devel@driverdev.osuosl.org
> Cc: b.a.t.m.a.n@lists.open-mesh.org
> Cc: linux-bluetooth@vger.kernel.org
> Signed-off-by: Florian Westphal <fw@strlen.de>
> ---

[...]

>  net/batman-adv/soft-interface.c                        | 2 +-

[...]

> diff --git a/net/batman-adv/soft-interface.c b/net/batman-adv/soft-interf=
ace.c
> index 0710379..bae1397 100644
> --- a/net/batman-adv/soft-interface.c
> +++ b/net/batman-adv/soft-interface.c
> @@ -208,7 +208,7 @@ static int batadv_interface_tx(struct sk_buff *skb,
>  	if (atomic_read(&bat_priv->mesh_state) !=3D BATADV_MESH_ACTIVE)
>  		goto dropped;
> =20
> -	soft_iface->trans_start =3D jiffies;
> +	netif_trans_update(soft_iface);
>  	vid =3D batadv_get_vid(skb, 0);
>  	ethhdr =3D eth_hdr(skb);
> =20


Acked-by: Antonio Quartulli <a@unstable.cc>

--=20
Antonio Quartulli

--hEk4XxIzAisM6naS
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAEBCAAGBQJXKi9qAAoJEJ4aZjxxc6bKdy0QAKpnm2haE6oZ01LtxQu1VfKB
Qer6rc7it+otFT8jIMkZ3Be9sL2++PZyMSivw0YZRQBHwv4vsauG8HeXUmnFGS9r
rTGv5P9Z0R1TrDTlZBXH0Pui6GIWlyKkxpRqqVu4q/xHmWH8Y2yLUXi/0BA5xB6L
3EPPoN/WyiCdZ/NGY8WJbuyF3H+UD0s8/YXLWbOGdzxZ4UgAJp5WPVr1QdvZ4Cl7
kqnB2g/KvHc6ruY9viT21FDjEdWvxTZlKYGbLJAQNyuM1IunThZQ/fOM82Rdtnj6
u46FixCz2AbHVnBZht+ODlnrypKj3jBdEXu1/YclguwBHzSnwdF2M7Wswpx38VZN
zkArU7t5LIZfiGqNpwXL0A7jovBRqI6FDJrynTKqJFjNTA/IZHwzZcWErXXp/4En
xD/9GPLK/Lr1dUY7vteYvIjzTq3YUfPsiRsMvdyhHlDU/KJWYPrJIjotjJgXCdcT
sLyCSGpSATmyZGhQW6BEkr3rm3y1fSOxQSD2Jmyv6sBXwaGSBpQzSalTgezUQjKm
GpARsJONS/PpV0PbIt660Of7OikWXgDOTR6z2Oe8tPt55D+UKoUHlfQU83dPm6m1
VW+3QZx2xue3jH05I8BeX6SKBVrtQfRh1nVi6xhkWgHaVahuh9BLgcPh2copDt/3
UB23coo6jv90cnkJg5FC
=6q9+
-----END PGP SIGNATURE-----

--hEk4XxIzAisM6naS--
