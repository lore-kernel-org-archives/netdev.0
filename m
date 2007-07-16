From: Toralf =?utf-8?q?F=C3=B6rster?= <toralf.foerster@gmx.de>
Subject: Re: build #307 failed for 2.6.22-g8f41958 in linux/./drivers/net/slip.c
Date: Mon, 16 Jul 2007 11:36:19 +0200
Message-ID: <200707161136.24332.toralf.foerster@gmx.de>
References: <200707161009.59675.toralf.foerster@gmx.de> <20070716083228.GA30605@2ka.mipt.ru>
Mime-Version: 1.0
Content-Type: multipart/signed;
  boundary="nextPart4419294.PEUdiTfCUM";
  protocol="application/pgp-signature";
  micalg=pgp-sha1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.gmx.net ([213.165.64.20]:53448 "HELO mail.gmx.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S1756300AbXGPJg1 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 16 Jul 2007 05:36:27 -0400
In-Reply-To: <20070716083228.GA30605@2ka.mipt.ru>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--nextPart4419294.PEUdiTfCUM
Content-Type: text/plain;
  charset="utf-8"
Content-Transfer-Encoding: quoted-printable
Content-Disposition: inline

Am Montag, 16. Juli 2007 10:32 schrieb Evgeniy Polyakov:
> This is a result of 'select' usage in Kconfig.
> Although this patch can help too.
>

Hi,
unfortunatly the patch doesn't help :

tfoerste@n22 ~/devel/linux-2.6 $ cp ../results/config.rnd.307 .config
tfoerste@n22 ~/devel/linux-2.6 $ make oldconfig 1>/dev/null
tfoerste@n22 ~/devel/linux-2.6 $ diff .config .config.old
4c4
< # Mon Jul 16 11:35:19 2007
=2D--
> # Mon Jul 16 09:43:31 2007



> Signed-off-by: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
>=20
> diff --git a/net/ieee80211/Kconfig b/net/ieee80211/Kconfig
> index 1438ade..a23414f 100644
> --- a/net/ieee80211/Kconfig
> +++ b/net/ieee80211/Kconfig
> @@ -1,5 +1,6 @@
>  config IEEE80211
>  	tristate "Generic IEEE 802.11 Networking Stack"
> +	depends on NET
>  	---help---
>  	This option enables the hardware independent IEEE 802.11
>  	networking stack.
>=20

=2D-=20
MfG/Sincerely

Toralf F=C3=B6rster

--nextPart4419294.PEUdiTfCUM
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.7 (GNU/Linux)

iD8DBQBGmzwUhyrlCH22naMRAsvpAJ9qaBVpPuB6Lpi4nzXGAVgjxbp7IQCfbRJz
O7oN3TWKiWnjbdVuCi1/OEA=
=saur
-----END PGP SIGNATURE-----

--nextPart4419294.PEUdiTfCUM--
