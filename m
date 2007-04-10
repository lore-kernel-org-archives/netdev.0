From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [PATCH] net: Add etun driver
Date: Tue, 10 Apr 2007 12:27:59 +0200
Message-ID: <1176200879.8459.77.camel@johannes.berg>
References: <m1ps6g5229.fsf@ebiederm.dsl.xmission.com>
	 <1176136628.8459.34.camel@johannes.berg> <461A70A5.8060607@trash.net>
	 <20070409.114402.45491411.davem@davemloft.net>
	 <m1mz1h1guo.fsf@ebiederm.dsl.xmission.com>  <461A9DF1.8080904@trash.net>
	 <1176150557.8459.47.camel@johannes.berg>  <461AD517.2000906@trash.net>
	 <1176184028.8459.58.camel@johannes.berg>  <461B4242.1040602@trash.net>
	 <1176196734.8459.74.camel@johannes.berg>  <461B5E42.2030900@trash.net>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-z49U5dsVeCED7YpRW7eF"
Cc: "Eric W. Biederman" <ebiederm@xmission.com>,
	David Miller <davem@davemloft.net>, akpm@linux-foundation.org,
	dim@openvz.org, netdev@vger.kernel.org, jgarzik@pobox.com,
	containers@lists.osdl.org, kuznet@ms2.inr.ac.ru,
	shemminger@linux-foundation.org, greearb@candelatech.com
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from crystal.sipsolutions.net ([195.210.38.204]:47334 "EHLO
	sipsolutions.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753294AbXDJK1u (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Apr 2007 06:27:50 -0400
In-Reply-To: <461B5E42.2030900@trash.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--=-z49U5dsVeCED7YpRW7eF
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Tue, 2007-04-10 at 11:52 +0200, Patrick McHardy wrote:

> Without having thought much about it yet, roughly like this:
>=20
> - driver receives RTM_NEWLINK message (under rtnl)
> - driver allocates new device
> - driver initializes device based on content of RTM_NEWLINK message
> - driver returns

Sounds good to me, but where's the advantage over something that isn't
generic if RTM_NEWLINK contains totally different things depending on
the subsystem like wireless where it'd have to contain the hardware
identifier?

johannes

--=-z49U5dsVeCED7YpRW7eF
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Comment: Johannes Berg (powerbook)

iD8DBQBGG2au/ETPhpq3jKURAlsCAKCQUFDzNmsEsE3ytXYnNhZcGze98gCfaKhX
2cMoF0JBSgszwFxuZ0tpUQc=
=s8Pm
-----END PGP SIGNATURE-----

--=-z49U5dsVeCED7YpRW7eF--

