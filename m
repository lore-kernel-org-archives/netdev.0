From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [PATCH] net: Add etun driver
Date: Tue, 10 Apr 2007 07:47:08 +0200
Message-ID: <1176184028.8459.58.camel@johannes.berg>
References: <m1ps6g5229.fsf@ebiederm.dsl.xmission.com>
	 <1176136628.8459.34.camel@johannes.berg> <461A70A5.8060607@trash.net>
	 <20070409.114402.45491411.davem@davemloft.net>
	 <m1mz1h1guo.fsf@ebiederm.dsl.xmission.com>  <461A9DF1.8080904@trash.net>
	 <1176150557.8459.47.camel@johannes.berg>  <461AD517.2000906@trash.net>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-phCWgN6prEtFR2zwuGF4"
Cc: "Eric W. Biederman" <ebiederm@xmission.com>,
	David Miller <davem@davemloft.net>, akpm@linux-foundation.org,
	dim@openvz.org, netdev@vger.kernel.org, jgarzik@pobox.com,
	containers@lists.osdl.org, kuznet@ms2.inr.ac.ru,
	shemminger@linux-foundation.org, greearb@candelatech.com
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from crystal.sipsolutions.net ([195.210.38.204]:51966 "EHLO
	sipsolutions.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1030351AbXDJFrI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Apr 2007 01:47:08 -0400
In-Reply-To: <461AD517.2000906@trash.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--=-phCWgN6prEtFR2zwuGF4
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Tue, 2007-04-10 at 02:06 +0200, Patrick McHardy wrote:

> Same way as the current RTM_SETLINK message works, but with creating
> a new link in advance. It works fine in other subsystems, so I don't
> see why it would in this case as well. Some subsystems do it in an
> atomic fashion (network schedulers for example), some first create
> the object, then configure it (network classifiers in the non-compat
> cases). In the network device case I suppose the later should work
> fine since a device needs to be set UP in a second action before
> it really does anything.

Our virtual devices are always associated with a piece of hardware, and
we really want them to be associated with that at all times, even when
not UP. Everything else seems like a huge complication if only because
then we can't have whoever will be responsible for the device allocate
it's private space area.

johannes

--=-phCWgN6prEtFR2zwuGF4
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Comment: Johannes Berg (powerbook)

iD8DBQBGGyTb/ETPhpq3jKURAtoDAJ9+JsW6DETvaTgVhLuHIGU+U2EDqwCfQEVu
XCLerQnx2d98MllRHvWBOac=
=u4EW
-----END PGP SIGNATURE-----

--=-phCWgN6prEtFR2zwuGF4--

