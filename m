From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [PATCH] net: Add etun driver
Date: Tue, 10 Apr 2007 15:48:08 +0200
Message-ID: <1176212889.8459.100.camel@johannes.berg>
References: <m1ps6g5229.fsf@ebiederm.dsl.xmission.com>
	 <1176136628.8459.34.camel@johannes.berg> <461A70A5.8060607@trash.net>
	 <20070409.114402.45491411.davem@davemloft.net>
	 <m1mz1h1guo.fsf@ebiederm.dsl.xmission.com>  <461A9DF1.8080904@trash.net>
	 <1176150557.8459.47.camel@johannes.berg>  <461AD517.2000906@trash.net>
	 <1176184028.8459.58.camel@johannes.berg>  <461B4242.1040602@trash.net>
	 <1176196734.8459.74.camel@johannes.berg>  <461B5E42.2030900@trash.net>
	 <1176200879.8459.77.camel@johannes.berg>  <461B6B22.3090009@trash.net>
	 <1176202930.8459.81.camel@johannes.berg>  <461B7060.8000407@trash.net>
	 <1176204297.8459.86.camel@johannes.berg>  <461B7D9A.50902@trash.net>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-XyAThWPwt8VY2c4T1D3d"
Cc: "Eric W. Biederman" <ebiederm@xmission.com>,
	David Miller <davem@davemloft.net>, akpm@linux-foundation.org,
	dim@openvz.org, netdev@vger.kernel.org, jgarzik@pobox.com,
	containers@lists.osdl.org, kuznet@ms2.inr.ac.ru,
	shemminger@linux-foundation.org, greearb@candelatech.com
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from crystal.sipsolutions.net ([195.210.38.204]:42154 "EHLO
	sipsolutions.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753761AbXDJNrk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Apr 2007 09:47:40 -0400
In-Reply-To: <461B7D9A.50902@trash.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--=-XyAThWPwt8VY2c4T1D3d
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Tue, 2007-04-10 at 14:05 +0200, Patrick McHardy wrote:
>=20
> I know too little about wireless to judge really this. My opinion is
> that if it is possible to add and configure an interface (even if
> only for simple cases) without knowledge about driver internals by
> setting a few parameters, it would probably make sense to use
> RTM_NEWLINK as well. If a userspace daemon or complex knowledge of
> driver internals is needed, it probably should stay seperated.

It still is though we're moving towards the userspace daemon thing.

> So simply put: if I can implement support for
> "ip wireless add dev wlan0 mode managed essid ... key ..."
> in less than 100 lines and get a working connection afterwards, it
> seems worth it.

For completely open networks (no "key ...") or just WEP (static key) it
could probably be done, but I don't see how right now.

johannes

--=-XyAThWPwt8VY2c4T1D3d
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Comment: Johannes Berg (powerbook)

iD8DBQBGG5WY/ETPhpq3jKURApOBAJwKR/rJ7lFnFEv5syfF3iuJRS1CcACgpSiE
ABh5Ac+S8J9YLfdskOJtM98=
=7DLb
-----END PGP SIGNATURE-----

--=-XyAThWPwt8VY2c4T1D3d--

