From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [PATCH] Fix Warnings from net/netlink/genetlink.c
Date: Tue, 11 Aug 2009 09:36:13 +0200
Message-ID: <1249976174.5903.16.camel@johannes.local>
References: <1249975630.2400.7.camel@HunTEr>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha1"; protocol="application/pgp-signature"; boundary="=-R7bSeh6x1oobAnnggjY/"
Cc: linux-next@vger.kernel.org, Thomas Graf <tgraf@suug.ch>,
	netdev <netdev@vger.kernel.org>
To: vibi_sreenivasan@cms.com
Return-path: <linux-next-owner@vger.kernel.org>
In-Reply-To: <1249975630.2400.7.camel@HunTEr>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--=-R7bSeh6x1oobAnnggjY/
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Tue, 2009-08-11 at 12:57 +0530, vibi sreenivasan wrote:
> Fix following compiler warnings
>=20
> net/netlink/genetlink.c: In function `genl_register_mc_group':
> net/netlink/genetlink.c:139: warning: 'err' might be used uninitialized i=
n this function

Well, only if there's no netns which can't happen.

However, technical problems prohibit your patch from being applied.

a) you sent it to the wrong list, copying netdev

> Signed-off-by: vibi sreenivasan, CMS COMPUTERS LTD, INDIA <vibi_sreenivas=
an@cms.com>

b) this isn't correctly formatted, have you actually read
Documentation/SubmittingPatches including the legal text that you're
agreeing to (section 12 of that document)?

johannes

>  net/netlink/genetlink.c |    2 +-
>  1 files changed, 1 insertions(+), 1 deletions(-)
>=20
> diff --git a/net/netlink/genetlink.c b/net/netlink/genetlink.c
> index 575c643..66f6ba0 100644
> --- a/net/netlink/genetlink.c
> +++ b/net/netlink/genetlink.c
> @@ -136,7 +136,7 @@ int genl_register_mc_group(struct genl_family *family=
,
>  {
>  	int id;
>  	unsigned long *new_groups;
> -	int err;
> +	int err =3D 0;
> =20
>  	BUG_ON(grp->name[0] =3D=3D '\0');
> =20


--=-R7bSeh6x1oobAnnggjY/
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----

iQIcBAABAgAGBQJKgR9qAAoJEODzc/N7+Qmat64P/2IniuUubyV5X9aDOnaWIxpj
mgMq6Pn3bjoPZUlAwaQAOnQz2CPclKk00G5fUSCoCbgNgAAE+HyJNmWG5Kre05+I
83zf6nLHgCWuhJk6A7bTigAgM8dEQxs2OWDsaelBBAvfU+rCjPROR2JZeQFYpqBa
4filsNgfZSVCrjq+UaZHhiASQ3EDmB5lUUwbwPF7bo/pjeFgK2wTcWALqSVGos43
sD+VqNQJkb/68+8dAHdBbtal286raBDfLA0v8aSW2PkSMU/L45nU6aioaikeusQK
u0/3hUKOsYg0W+EhkZ102bwk4dU6ewpHkhcsI3XkM5Lri+LeA5BKbpGKGZDbu8dY
q4eDOaTPLnTtbz727KJjPt0nuo5iFckQyC1zEPePYHXiacKRVlRzQKlpWMIg1tvT
xhjLhzRoXndGWC1+eQjmC9jy2qYxyaBzUkJ7Td309lT/vFofQzIH+A5in2t7HDFP
HqO9GjnCKJJEh8JZ4sxtHRgKv7mH2A/n/j8b0pTtwsL5yitvJY6dIs86XVrpqP+h
bQS17j1HiCs5CEK2PwDVkOFFyqQ4rynDjpMqKo9JBWtJKDtA+oYhOB5Vq8PjijSM
q9kznL98JQCpO2MaDSt9lThf2dzu3j5H45t+ypn9IVW9p5Tsn+xNtYd2g5dP8kIc
nzBssS9NKEfRCq/nV+c9
=iJ1q
-----END PGP SIGNATURE-----

--=-R7bSeh6x1oobAnnggjY/--
