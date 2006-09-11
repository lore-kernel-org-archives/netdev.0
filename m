From: Carlos =?utf-8?Q?Mart=C3=ADnn?= Nieto <carlos@cmartin.tk>
Subject: Re: tiacx module fail
Date: Mon, 11 Sep 2006 22:03:43 +0200
Message-ID: <20060911200343.GA3878@kiopa.cmartin.tk>
References: <4503F640.3040300@fastwebnet.it> <20060911122541.GA4537@kiopa.cmartin.tk> <450560F6.5030405@fastwebnet.it>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="zhXaljGHf11kAtnf"
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 111.red-82-159-197.user.auna.net ([82.159.197.111]:41690 "EHLO
	indy.cmartin.tk") by vger.kernel.org with ESMTP id S965022AbWIKUE0
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 11 Sep 2006 16:04:26 -0400
To: VinX <vincenx@fastwebnet.it>
Content-Disposition: inline
In-Reply-To: <450560F6.5030405@fastwebnet.it>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--zhXaljGHf11kAtnf
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

 Did you bring the interface up (ifconfig eth1 up)? It won't work
before that because parts of the card haven't been initialised.

 IIRC, the tiacx module in wireless-2.6 uses softmac and we never
managed to get it working properly. There is a version with the
devicescape stack which seems to work, though it might take a bit of
hunting down.

--=20
Carlos Mart=C3=ADn Nieto    |   http://www.cmartin.tk
Hobbyist programmer    |
--zhXaljGHf11kAtnf
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.5 (GNU/Linux)

iD8DBQFFBcEfEVXxXOiy6a4RAtTWAKCRdemCOgH9/btiLbteaT3Yxhg2/ACfcSjI
MSHlsaLM1tI28HvkVG6gR48=
=r1MK
-----END PGP SIGNATURE-----

--zhXaljGHf11kAtnf--
