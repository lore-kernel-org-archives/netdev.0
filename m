From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [PATCH wireless-dev] Remove struct pt_regs * from d80211
	drivers
Date: Fri, 13 Oct 2006 21:36:01 +0200
Message-ID: <1160768161.5534.4.camel@johannes.berg>
References: <200610131405.54929.flamingice@sourmilk.net>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-Uv5jI2Fga2h9wVYUewpJ"
Cc: John Linville <linville@tuxdriver.com>, netdev@vger.kernel.org,
	Michael Buesch <mb@bu3sch.de>,
	Ivo van Doorn <ivdoorn@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from crystal.sipsolutions.net ([195.210.38.204]:44466 "EHLO
	sipsolutions.net") by vger.kernel.org with ESMTP id S1751841AbWJMThQ
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 13 Oct 2006 15:37:16 -0400
To: Michael Wu <flamingice@sourmilk.net>
In-Reply-To: <200610131405.54929.flamingice@sourmilk.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--=-Uv5jI2Fga2h9wVYUewpJ
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Fri, 2006-10-13 at 14:05 -0400, Michael Wu wrote:
> Remove struct pt_regs * from d80211 drivers

Thanks, I was about to do that as well. You forgot at least one place
where the irq handler is called 'manually' in bcm43xx though.

johannes

--=-Uv5jI2Fga2h9wVYUewpJ
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Comment: Johannes Berg (powerbook)

iQIVAwUARS/qoKVg1VMiehFYAQLwIA//YD/OgshjX0SU2j5YMjjxfSsAR2/OCZqm
cOguBExAMqeRLqLcdaoHxEUM/8OPMspt1cNLs3AI6f0BGZEm5Ow4XNBjPE1+sv+9
CDghmGpQE80zHoh/lwIYqFXv+PVwkrU0EETZR98AiGZ3cadY79l/KlY8/wt/PZGs
9C2VMLRlV8xVFs1EAcxU1UIQQ4nRl4LCWpQS2/ex5J7QdV26sWK/hx9oG1ETuU+H
UMrWX/vrRvGusBNuGALHU4Fsl3u0tFKPXYe7+nCdJzv4wFTY5YVn6AynCqg3RJ4q
e4bb9JFiD92x8don90taRmynucgHNLH0+9uG3/Clq/B3/HiY9b1aPyGKaGu5hZjH
7DZ9y8dFWZ6lNjSGmhxkwIfQ6bdebLeoJ9s5RoNZdv6dbxOMnNzUV4Nq6SIj7Hnn
K+ZI4VCOOSWOm8vJM5bP9FcM2hvLukIRFm5R1EZ0FRjb87wX/mMWWOQOhpgRxHqR
anIiE3l0pOSLPXJ6FlcJ59tIm3qHw15JVrZPrxIGTRlLX40e1CvmhyDuzMw5zdGt
41/KlYKtzeFSwAjZQLnSMVrd1HdVZYdkaz+1jxj9eKviBk9YdzzT9XK+xej2ENV7
wCtQtFsRoau+fvMU0O9QnLjk3/QWqKw6wpfUfHnTuz1cG8DMrgMhNph7N7IjniqD
3Y3drf21MmU=
=Eu50
-----END PGP SIGNATURE-----

--=-Uv5jI2Fga2h9wVYUewpJ--

