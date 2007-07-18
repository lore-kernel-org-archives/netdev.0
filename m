From: Florian Fainelli <florian.fainelli@telecomint.eu>
Subject: Re: [PATCH] Add a network activity LED trigger
Date: Wed, 18 Jul 2007 15:44:11 +0200
Message-ID: <200707181544.11890.florian.fainelli@telecomint.eu>
References: <200707181527.38895.florian.fainelli@telecomint.eu> <469E16C5.4000102@trash.net>
Mime-Version: 1.0
Content-Type: multipart/signed;
  boundary="nextPart5093225.ldjykLU1dq";
  protocol="application/pgp-signature";
  micalg=pgp-sha1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, rpurdie@rpsys.net
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-ext.int-evry.fr ([157.159.11.17]:49677 "EHLO
	smtp-ext.int-evry.fr" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753119AbXGRNn5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Jul 2007 09:43:57 -0400
In-Reply-To: <469E16C5.4000102@trash.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--nextPart5093225.ldjykLU1dq
Content-Type: text/plain;
  charset="iso-8859-15"
Content-Transfer-Encoding: quoted-printable
Content-Disposition: inline

Hello Patrick,

Le mercredi 18 juillet 2007, Patrick McHardy a =E9crit=A0:
> Module isn't possible, you call the led trigger from net/core/dev.c.

You are right, it just occured to me.

> Besides missing a declaration and not linking without the network
> LED config option, its pretty ridiculous to call this for every
> packet just to make a led blink.

Could you suggest me a better way to do so ? The code was highly inspired f=
rom=20
what is done with the IDE trigger. The declaration is done in linux/leds.h,=
=20
which is included in dev.c for that purpose.

Thank you very much for your answer.

--nextPart5093225.ldjykLU1dq
Content-Type: application/pgp-signature; name=signature.asc 
Content-Description: This is a digitally signed message part.

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.5 (GNU/Linux)

iD4DBQBGnhkrmx9n1G/316sRAv5lAJjYRT+2AVK98A9Yhl9rY5WEZeWBAKCLM9MF
U3vJ1dJhyaSBe7SZPjeeTw==
=uLH8
-----END PGP SIGNATURE-----

--nextPart5093225.ldjykLU1dq--
