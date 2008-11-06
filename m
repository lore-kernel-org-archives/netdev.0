From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [PATCH] SSB: make it depend on PCI
Date: Thu, 06 Nov 2008 12:07:00 +0100
Message-ID: <1225969620.3619.204.camel@johannes.berg>
References: <1225965082-31462-1-git-send-email-vapier@gentoo.org>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-k2D2UspsRpvOeLYm3urI"
Cc: Michael Buesch <mb@bu3sch.de>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Mike Frysinger <vapier@gentoo.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from xc.sipsolutions.net ([83.246.72.84]:38491 "EHLO
	sipsolutions.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752589AbYKFLG7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 6 Nov 2008 06:06:59 -0500
In-Reply-To: <1225965082-31462-1-git-send-email-vapier@gentoo.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-k2D2UspsRpvOeLYm3urI
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Thu, 2008-11-06 at 04:51 -0500, Mike Frysinger wrote:
> Since the SSB code requires PCI, set the Kconfig dependencies accordingly=
.
> Also tweak the menu display so that the menu does not show up at all if
> SSB is not possible.
>=20
> Signed-off-by: Mike Frysinger <vapier@gentoo.org>
> ---
>  drivers/ssb/Kconfig |    7 ++++---
>  1 files changed, 4 insertions(+), 3 deletions(-)
>=20
> diff --git a/drivers/ssb/Kconfig b/drivers/ssb/Kconfig
> index 307b1f6..f0a176a 100644
> --- a/drivers/ssb/Kconfig
> +++ b/drivers/ssb/Kconfig
> @@ -1,10 +1,11 @@
> -menu "Sonics Silicon Backplane"
> -
>  config SSB_POSSIBLE
>  	bool
> -	depends on HAS_IOMEM && HAS_DMA
> +	depends on HAS_IOMEM && HAS_DMA && PCI

This is incorrect. SSB is also used on embedded systems that do not use
PCI at all.

johannes

--=-k2D2UspsRpvOeLYm3urI
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Comment: Johannes Berg (powerbook)

iQIcBAABAgAGBQJJEs/JAAoJEKVg1VMiehFYMx0P+wZmvhZGe0f2jiUG/SwHpgcb
EIaG+BGMdjTcAAp1Vzpnr14rhUJaFigIdNcIQKf38vkVoj+4g5EMq9b2OhQkNPnX
l0qprRMp1r310F40vtKM1gSRHCId+BcFtwE3JcVrS28n49UledC6u1O8cpt1wqrx
H7BspDmwUbw9j0JlqFkUDfWp234YisjmiQZ92xXQlQgi+FB6Xg7StxnynzYI18cq
4PmcHCSPq0zdILhpexwzf2+mTRYh2wYal6BqeIXTP/4QRUItQ/+SFcmSHrPkRkj3
bI/BqDMe1B5oFKtzQ5HradMB8bhCUJPDAkRwHJ8qCb1cTnbUdaPCXtWx+jeuRw0F
LBxtFdS2yf00OMe5mkhMQIDwyz6kggYoizlVC/6f+j27kR9fAtnAc1r+NcnaAred
nmOsOz8uxlyCyonkgAn5yUU8zQ1p9/XVhie9su4K1q0mHxAUnXZFB0258GuLcl5f
ZS7yF6hDbzF8VEX9qYzxj9bPM3j7jN12mBjSlOgQAz1ImfsULcUEfO4Ag9yLM1cf
T6eNdgKvoARK1MB+TIehZ2SsjsS8kSPQZSE4ohIf0H30+FGvhPVY/YiTic5AX8jC
wT88ulD43hUR895ktCNmNDa6/TqLZ9kx+qbLSKNOE+mZgfrUwZDRTJQm0+PZxu5r
Etk+2VR7FRQUDVDQQwEF
=LrIU
-----END PGP SIGNATURE-----

--=-k2D2UspsRpvOeLYm3urI--

