From: Sergei Trofimovich <slyich@gmail.com>
Subject: Re: 3.0.0-rc1: dmesg shows 'wlan%d' instead of 'wlan0'
Date: Mon, 6 Jun 2011 20:32:52 +0300
Message-ID: <20110606203252.1854e4d7@sf>
References: <20110605201042.21c86763@sf>
	<BANLkTimLXr1+OLtGGXE2kzccRRG5T-G2mw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=PGP-SHA1;
 boundary="Sig_/jj9.r26ILmc22Vhoji_+JUq"; protocol="application/pgp-signature"
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Mohammed Shafi <shafi.wireless@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f46.google.com ([209.85.214.46]:57761 "EHLO
	mail-bw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754131Ab1FFRaB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 Jun 2011 13:30:01 -0400
In-Reply-To: <BANLkTimLXr1+OLtGGXE2kzccRRG5T-G2mw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--Sig_/jj9.r26ILmc22Vhoji_+JUq
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable

> > Here we see 'wlan0' -> 'wlan%d' switch. I presume those lines go from f=
irmware
> > (and not from userspace).

> this seems to be fixed by the following commit which was recently
> merged in wireless-testing
>=20
> commit 59e7e7078d6c2c6294caf454c6e3695f9d3e46a2
> Author: Thadeu Lima de Souza Cascardo <cascardo@holoscopio.com>
> Date:   Thu Jun 2 17:28:37 2011 -0300

> are we still getting it?

I never ran 'wireless-testing' before.

Applied this commit on top of 3.0-rc2 and wlan%d switched to wlan0 back.

Thanks!

--=20

  Sergei

--Sig_/jj9.r26ILmc22Vhoji_+JUq
Content-Type: application/pgp-signature; name=signature.asc
Content-Disposition: attachment; filename=signature.asc

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.17 (GNU/Linux)

iEYEARECAAYFAk3tD0YACgkQcaHudmEf86rf8QCfXRTQ2CsG4cjRoZrhP9AfsCYW
gzMAniPXfLGSQSsFq5t+l6yFTJaPjMpC
=j2qX
-----END PGP SIGNATURE-----

--Sig_/jj9.r26ILmc22Vhoji_+JUq--
