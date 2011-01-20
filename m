From: Ben Hutchings <ben@decadent.org.uk>
Subject: Re: Bug#609538: r8169: long delay during resume
Date: Thu, 20 Jan 2011 03:20:03 +0000
Message-ID: <1295493603.2906.107.camel@localhost>
References: <AANLkTikxpOS2fJ1Sqv=Lg6cX1TE+1W-ZxFV+YMOH1+Yp@mail.gmail.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha1"; protocol="application/pgp-signature"; boundary="=-3LA1FU4ZImDi4DxbYyn3"
Cc: Francois Romieu <romieu@fr.zoreil.com>,
	netdev <netdev@vger.kernel.org>,
	Hayes Wang <hayeswang@realtek.com>
To: Daniel J Blueman <daniel.blueman@gmail.com>, 609538@bugs.debian.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shadbolt.e.decadent.org.uk ([88.96.1.126]:49667 "EHLO
	shadbolt.e.decadent.org.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754842Ab1ATDUN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Jan 2011 22:20:13 -0500
In-Reply-To: <AANLkTikxpOS2fJ1Sqv=Lg6cX1TE+1W-ZxFV+YMOH1+Yp@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-3LA1FU4ZImDi4DxbYyn3
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Thu, 2011-01-20 at 10:04 +0700, Daniel J Blueman wrote:
> When resuming from suspended with 2.6.38-rc1 with my RTL8168d/8111d
> hardware, I see significant delays [1].
>=20
> The only firmware I see in /lib/firmware is RTL8192E, thus it looks
> like this is due to it being not present.

If you're using Debian, the necessary blob is in the firmware-realtek
package.

> I see that Francois' patch is present in 2.6.38-rc1; is there a way to
> avoid this delay, or is this likely in request_firmware?
[...]

It's a known problem with calls to request_firmware() when userland is
not running (early initialisation or resume from sleep).  It may be
fixable.

Ben.

--=20
Ben Hutchings
Once a job is fouled up, anything done to improve it makes it worse.

--=-3LA1FU4ZImDi4DxbYyn3
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.10 (GNU/Linux)

iQIVAwUATTep3ue/yOyVhhEJAQLKrA//fxMFCpT+EPA+QFesSbL0/aN2Dur1aXwC
Svw2TenDPTC3rIonu5AypT1OY2/3mbVhT80lYZW4fuNpiQc+1Lsla1yvxmHyNJck
nNM5FWlOWss6ZmiLrjxbO2N43aCV/fhJbXeclmKdChDWYL5iGKUZQl8jsGJvPLQG
At50m3LB97t4BBzc1c3cZIFvG/vvAUxv5+qs79CTQ7Uz2AkaYGW8Ox5RZ4jvAsp5
WvLlHlb9Imia7NhcI5wyHUI8n8UajTNuM1faAZ/twQZ5JurPmzOp5g0ZWEUnIq8j
fquaujl8aeXwuHB301HOWuU8agfSXSEs101W0jrOxYL0mvF9v1tfhJeyBgrj2Ya0
Pqc/1oY6WVVZvUd92HjLhMTQuCKrOXZh6CZuoi7YE1FNXUvfneO2AKFd5UseC6rh
MBTy94vGKfHtSnTErZqJqY0NXmFQb58fBdkjhsPydyk5oeDiFi9EXIjvUiFioz1/
/R0M5STV0L4IR4etsqnI+IBYgg1SMLDJRrF4x0+W7PmqtHYpFn+XvhJgkUH6xOXr
4vWugjniXfcXHbrGBx2oLWDGrSCulJJaBRqO23JMQZqI54zi1cL87bcjaMqlroMt
m4dDmuQEEx6hQxJrTUekqMVwxACvNNuPPJX+HRd+GyQ1As3GDPK+OI/wtUtBcAJ7
eI0EgreqAQ8=
=Vfpv
-----END PGP SIGNATURE-----

--=-3LA1FU4ZImDi4DxbYyn3--
