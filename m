From: Toralf =?utf-8?q?F=C3=B6rster?= <toralf.foerster@gmx.de>
Subject: Re: build #307 failed for 2.6.22-g8f41958 in linux/./drivers/net/slip.c
Date: Mon, 16 Jul 2007 12:24:55 +0200
Message-ID: <200707161224.58831.toralf.foerster@gmx.de>
References: <200707161009.59675.toralf.foerster@gmx.de> <200707161136.24332.toralf.foerster@gmx.de> <20070716094735.GA10334@2ka.mipt.ru>
Mime-Version: 1.0
Content-Type: multipart/signed;
  boundary="nextPart2408750.FLHmy4nbur";
  protocol="application/pgp-signature";
  micalg=pgp-sha1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.gmx.net ([213.165.64.20]:56606 "HELO mail.gmx.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S1755443AbXGPKZD (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 16 Jul 2007 06:25:03 -0400
In-Reply-To: <20070716094735.GA10334@2ka.mipt.ru>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--nextPart2408750.FLHmy4nbur
Content-Type: text/plain;
  charset="utf-8"
Content-Transfer-Encoding: quoted-printable
Content-Disposition: inline

Right,

applying the patch below to the git tree removes the build failure.

Am Montag, 16. Juli 2007 11:47 schrieb Evgeniy Polyakov:
> On Mon, Jul 16, 2007 at 11:36:19AM +0200, Toralf F=C3=B6rster (toralf.foe=
rster@gmx.de) wrote:
> > Am Montag, 16. Juli 2007 10:32 schrieb Evgeniy Polyakov:
> > > This is a result of 'select' usage in Kconfig.
> > > Although this patch can help too.
> > >
> >=20
> > Hi,
> > unfortunatly the patch doesn't help :
>=20
> It does not help with llc because of select usage.
> Netdevices likely should also depend on net.
>=20
> diff --git a/drivers/net/Kconfig b/drivers/net/Kconfig
> index ba314ad..c2ab077 100644
> --- a/drivers/net/Kconfig
> +++ b/drivers/net/Kconfig
> @@ -4,6 +4,7 @@
>  #
> =20
>  menuconfig NETDEVICES
> +	depends on NET
>  	default y if UML
>  	bool "Network device support"
>  	---help---
>=20
>=20

=2D-=20
MfG/Sincerely

Toralf F=C3=B6rster

--nextPart2408750.FLHmy4nbur
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.7 (GNU/Linux)

iD8DBQBGm0d3hyrlCH22naMRAvijAJ4sNK6OT/nSHNfNCqTX2GLLg8XOZQCfR9UR
McauK03GVobOe4qAewazAmk=
=mVU5
-----END PGP SIGNATURE-----

--nextPart2408750.FLHmy4nbur--
