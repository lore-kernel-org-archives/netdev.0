From: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
Subject: Re: [PATCH 1/2] net: introduce NETDEV_POST_INIT notifier
Date: Mon, 28 Sep 2009 11:29:23 +0200
Message-ID: <1254130163.6583.20.camel@johannes.local>
References: <1254126089.6583.18.camel@johannes.local>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha1"; protocol="application/pgp-signature"; boundary="=-0uyeY+YOv0XPyBMT/sTl"
Cc: linux-wireless <linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Hugh Dickins <hugh.dickins-IWqWACnzNjwqdlJmJB21zg@public.gmane.org>,
	Marcel Holtmann <marcel-kz+m5ild9QBg9hUCZPvPmw@public.gmane.org>
To: netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1254126089.6583.18.camel-YfaajirXv2244ywRPIzf9A@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org


--=-0uyeY+YOv0XPyBMT/sTl
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Mon, 2009-09-28 at 10:21 +0200, Johannes Berg wrote:
> For various purposes including a wireless extensions
> bugfix, we need to hook into the netdev creation before
> before netdev_register_kobject(). This will also ease
> doing the dev type assignment that Marcel was working
> on for cfg80211 drivers w/o touching them all.
>=20
> Signed-off-by: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
> ---
> I decided that it doesn't make a lot of sense to be after ndo_init but
> before the other name/... checks.

Ignore this patch please, I have something better. Marcel, feel free to
pick this up once you continue working on your devtype thing.

johannes

--=-0uyeY+YOv0XPyBMT/sTl
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----

iQIcBAABAgAGBQJKwIHwAAoJEODzc/N7+QmamzoP/R531Auz0xfIDvWzc/fnpZO7
b4NbXTCFNpHnJAKWz96s0n/WEsvODnUKZsDq3T0Z63vOQgax3yeJFAkjzJIPDVOS
RRLKZQxC3InC/VczSV2ethb0dbkcZcfcW64t9fu+zV1EQW0y8VvTfqvJMDnTCcRn
nfqIc08DcQ3bJ/LPm7DErGtbF2CJ86a31gnCLrwFhhuKIqhP0+il0o1G2n7WzbCt
HkX67a1owek/ZS+gq2lHc9xxvXwEPZz527lkfMrBLOzifYSgKupn3rL6ACr8e8er
y++CPzFC7q3vnNYHFvTCwDaJRxtINP5mWBHYFAMBcG1EeecyUFwUPrdxeXGAISUN
qxaITEykozakP0lo70FZFTORClfnw0yCY+jCUt9rKenDfCe60joDHbK/fHVfyzeQ
CslRT4CsSW+Q3/B6zRXoYVekYgKwGKrtfPwhC1LKVr6ALz0ksUo6plgf/6HPk2aD
Gk369WU+delYdkoVSjyLIdIsUmQ19aCUhoVkvU2czcz0qgFlpA5nQIzHRsw0l8oM
aZjDGopRwOCPHNLgWqudI5rO7Wio21Bqc2EiZUDevrnvDoSvZEiTLhTqJQAxJyYI
1NnqMVpln2iTZKqrjAmgKuOP7/uPiA6lfMTNkO3LACp/FJD93LjrbAwJ7lLV6ieb
0/61UB2mP5vY7rEkekyb
=escH
-----END PGP SIGNATURE-----

--=-0uyeY+YOv0XPyBMT/sTl--

--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
