From: Thomas Haller <thaller@redhat.com>
Subject: Re: [patch iproute2 2/2] iplink: print out addrgenmode attribute
Date: Tue, 06 Jan 2015 17:52:33 +0100
Message-ID: <1420563153.2527.14.camel@hal>
References: <1420561426-3118-1-git-send-email-jiri@resnulli.us>
	 <1420561426-3118-2-git-send-email-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha1"; protocol="application/pgp-signature";
	boundary="=-yOUl6tRkyYZdCiPp4GPs"
Cc: netdev@vger.kernel.org, stephen@networkplumber.org
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:37101 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752073AbbAFQwl (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 6 Jan 2015 11:52:41 -0500
In-Reply-To: <1420561426-3118-2-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-yOUl6tRkyYZdCiPp4GPs
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Tue, 2015-01-06 at 17:23 +0100, Jiri Pirko wrote:
> addrgenmode is currently write only by ip. So display this information
> if provided by kernel as well.

> =20
> +static void print_af_spec(FILE *fp, struct rtattr *af_spec_attr)
> +{
> +	struct rtattr *inet6_attr;
> +	struct rtattr *tb[IFLA_INET6_MAX + 1];
> +
> +	inet6_attr =3D parse_rtattr_one_nested(AF_INET6, af_spec_attr);
> +	if (!inet6_attr)
> +		return;
> +
> +	parse_rtattr_nested(tb, IFLA_INET6_MAX, inet6_attr);
> +
> +	if (tb[IFLA_INET6_ADDR_GEN_MODE]) {
> +		switch (rta_getattr_u8(tb[IFLA_INET6_ADDR_GEN_MODE])) {
> +		case IN6_ADDR_GEN_MODE_EUI64:
> +			fprintf(fp, "addrgenmode eui64 ");

eui64 is the default and the behavior of older kernels.

I dunno, would it be better not to print the default case?


Thomas

--=-yOUl6tRkyYZdCiPp4GPs
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAABAgAGBQJUrBLRAAoJECnCNm5N/FcorM0P/2tF7z6He9bqhpYEpn7eay+P
7paFF7yAscqCIokwm+tla6piurkwXuV/SH9KdldFbRC/tJqXncbBGXHGi38LoKXK
cxvAyBfm9S2BrVN7mXyd66Ve65CW0pj01Jhw4MpcIyzzGJilGD6MHEVkv7rWtgqg
znCqcNCJlCfOZagxTt/blhshIOK+NpNtj9bUhp26BuqckVL29YkQFm9qJI2jfBvt
KCKbwtDcfJVdraIpU1KGjSd6LNGzMyrnmIcYqwY2YF3M/wAMXLZ4HDwv0/feWn2q
B3Sq2ySb+zCmOa7dE0zLvFvLUvpTrSml4S0NEhueSvpoWgcx9PoxICnvTluZvnGe
hBr1y3+mAGP7ByMvBOVpJeThTQr2zAgcuPYhqTQBbeuvhj7QQtRlpwvu5spmAQYU
UXNdnvi+hWg94+b+vJmVWhoAEZfCVzx8pzkbwXLeyeFNkrSw6MHk0ctKsFAleGTT
ay7YLcjgy1uNc6IjUZKIW3jsDbF6Fx/L4I00OXfFTP0vApFQHyhU8JVrw7SwjvdH
/wlUIDK/H51XuQ5SMJyDlBj57+V++ofZ+JRYkuXe7ShzErZ59jk2JrZOr6oG8pNx
SRoHYTcgP5WSPlSi40gIlQZuwo24xWUnKaSmgYYJl1s6ZwVLoJNh+PIvO2PHh0EY
mbJsDVrrZiLoUZNve8VJ
=N5Ty
-----END PGP SIGNATURE-----

--=-yOUl6tRkyYZdCiPp4GPs--
