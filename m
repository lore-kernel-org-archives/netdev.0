From: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
Subject: Re: [PATCH 66/77] mac80211_hwsim: convert to internal
 net_device_stats
Date: Sat, 21 Mar 2009 12:08:25 +0100
Message-ID: <1237633705.5100.172.camel@johannes.local>
References: <20090321053527.316395697@vyatta.com>
	 <20090321053717.601771143@vyatta.com>
	 (sfid-20090321_065122_704364_56BF32DB)
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha1"; protocol="application/pgp-signature"; boundary="=-+LgtfH3UK7gX+rqusvej"
Cc: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>, j@w1.fi,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Stephen Hemminger <shemminger-ZtmgI6mnKB3QT0dZR+AlfA@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20090321053717.601771143-ZtmgI6mnKB3QT0dZR+AlfA@public.gmane.org> (sfid-20090321_065122_704364_56BF32DB)
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org


--=-+LgtfH3UK7gX+rqusvej
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Fri, 2009-03-20 at 22:36 -0700, Stephen Hemminger wrote:
> plain text document attachment (hwsim.patch)
> Signed-off-by: Stephen Hemminger <shemminger-ZtmgI6mnKB3QT0dZR+AlfA@public.gmane.org>
>=20
>=20
> --- a/drivers/net/wireless/mac80211_hwsim.c	2009-03-20 21:45:40.802964051=
 -0700
> +++ b/drivers/net/wireless/mac80211_hwsim.c	2009-03-20 22:26:02.959027480=
 -0700
> @@ -739,10 +739,16 @@ static struct device_driver mac80211_hws
>  	.name =3D "mac80211_hwsim"
>  };
> =20
> +static const struct net_device_ops hwsim_netdev_ops =3D {

this, and a few others I think, have wrong subjects.

johannes

--=-+LgtfH3UK7gX+rqusvej
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Comment: Johannes Berg (powerbook)

iQIcBAABAgAGBQJJxMqmAAoJEKVg1VMiehFYcFcP/35fdtwRFoILNM9hKj7kEasT
DgTYVDn4dgwbs/piT+Ob5qQnPXfGFgMDLNES9vOietk58pa3ayUJxBCfZUHy+5zg
aAh3iKoPwcci7YbHScvrRZSGMDUgjjy3hFRHO4x6VF9RVBcPZIPnzzXV739xTUG3
av/u0xTNRXwmDLvfbSevnB9QxErIzCkZ23QuuzK6OrUwGx0hblz55HvPdCnO/8Em
jEDfDQCHceyS9XEFnSURpeZ/U8mVBpHhAF7v+ARobyjDgjgJp43RbNbz5EUNA2Pm
d0NbtniYKV8FM5aA0EzZt51pDQ+beuO4GiisfXvaStHI2CtM3w2EM2pcx/tSiLyh
NfrLWZ4THQEjlcjr+0Z/APwG7t7eXnnLItWjK7RUwm/swN6WZqBqPaQjggqKWTHo
TyzYLFamEiHPIeGihLFuTejFX1S2QOrsgaSu1MnekZH9dP+m+Be7uFcsB8s8WFwI
FTe9URqw0iL9iKbhwTrkHqewm6hLPS0Ze3yS3/Ip80U6nQ0qC3KlLzkFQ/QGLOLD
QcqOfnoKITCWByBPknNy80wMpNbDQNciaK137Y9/dcTpgSAFjll+DzFPd6qQ7gfw
PJifxZU8cS+Q2D3TqoGBCMWrpn0OJszrOF6Jh81K+gK8X+647MqtKuS1zC25lCNU
K1wawfAmjy+0kOZQEF1e
=XNu5
-----END PGP SIGNATURE-----

--=-+LgtfH3UK7gX+rqusvej--

--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
