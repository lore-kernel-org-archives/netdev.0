From: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
Subject: Re: 2.6.29-rc8: Reported regressions from 2.6.28
Date: Sun, 15 Mar 2009 19:11:05 +0100
Message-ID: <1237140665.24621.2.camel@johannes.local>
References: <MiincthRUSI.A.eKC.F4BvJB@chimera>
	 <b6a2187b0903141958u9dae0fdk1f44b387108b99e4@mail.gmail.com>
	 <b6a2187b0903142006u546fad9eme66f9ea7b464b81f@mail.gmail.com>
	 (sfid-20090315_040645_344726_0E746861)
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha1"; protocol="application/pgp-signature"; boundary="=-AVqk3u9ur7XpbtCSWx/D"
Cc: "Rafael J. Wysocki" <rjw-KKrjLPT3xs0@public.gmane.org>,
	Linux Kernel Mailing List <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Adrian Bunk <bunk-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
	Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>,
	Linus Torvalds <torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>,
	Kernel Testers List <kernel-testers-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Network Development <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
To: Jeff Chua <jeff.chua.linux-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <kernel-testers-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <b6a2187b0903142006u546fad9eme66f9ea7b464b81f-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org> (sfid-20090315_040645_344726_0E746861)
Sender: kernel-testers-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org


--=-AVqk3u9ur7XpbtCSWx/D
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Sun, 2009-03-15 at 11:06 +0800, Jeff Chua wrote:

> The commit below is causing problem with associating with the hidden AP a=
s well.

> 71c11fb57b924c160297ccd9e1761db598d00ac2 is first bad commit
> commit 71c11fb57b924c160297ccd9e1761db598d00ac2
> Author: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
> Date:   Tue Oct 28 18:29:48 2008 +0100
>=20
>     b43/legacy: remove SSID code
>=20
>     The SSID programmed into the device is used by the ucode only
>     to reply to probe requests, a functionality we disable anyway
>     because it doesn't fit with the mac80211/hostapd programming
>     model. Therefore, it isn't useful to program the SSID into
>     device.

That's not believable, sorry. I know exactly what the microcode uses the
SSID here for, and it never uses it when we're in station mode.

johannes

--=-AVqk3u9ur7XpbtCSWx/D
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Comment: Johannes Berg (powerbook)

iQIcBAABAgAGBQJJvUS3AAoJEKVg1VMiehFYHbwP/23mwPlFgJ1/pUMeENy0CwWl
4gbwtEUoSPS4s4V4iakJNBLxmcBpv0txZzrkZo7XpFtoCyCo2w3gzd8swrkN/ZCJ
1IQekBsbfVxGH14CoOg/V+/K0m53nr+bqkW/7aFDGpS/0KyLEsLecvZHDOKaw6nP
2AKXrpnCupqjmDVySnaRMrUp7zd3oarRhxmkZFp7lOxfrFGT0gMkBqML4kAsHd/Y
tp3of6TOj5lsmIemitokGhPPVENXMZUorZyTbAo/HPFDBGY+07OJVsis90uZTPtT
3DjRSJNvs7s4e0YQHyQvROo3j7WphcPlPLLj+VT/+uYkHnmfv7no6PCnpRgLcdjO
xLRRQxGj47bMIikdimjTk7gH84eObTqjaXXnUaqAh6CMORyMUXXawMyqu7G8JIId
S9DEzYR6sAq1x8RT3wuH1DssTsCxN2xWKU8BSi+B0ZrbjqkCLp2G4q93Av+yWSNQ
9p8mHiJiCyicXnTHsbPve+MsFbAJ4YnbOyi9lvl5giX6hDGHrXHoaX5Ic4nsLn4d
kZoelPLCo6c1iD1wxk43q69K0c9IVZe6Ox9v3pFw/sKDaq1d8RHvt0XX21ADYAIU
lnL3x9HQWP94TfB0jJdd/0inRrePsgHzpqXQOcx5sof+4gYaQdZrP0anHNc3JzNr
t6sZVt0jm43S6jCLTwFB
=3LKL
-----END PGP SIGNATURE-----

--=-AVqk3u9ur7XpbtCSWx/D--
