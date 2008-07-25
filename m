From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: Kernel WARNING: at net/core/dev.c:1330
	__netif_schedule+0x2c/0x98()
Date: Fri, 25 Jul 2008 21:36:15 +0200
Message-ID: <1217014575.4758.7.camel@johannes.berg>
References: <1216806614.7257.152.camel@twins>
	 <1216810696.7257.175.camel@twins>
	 <20080723.131441.200166513.davem@davemloft.net>
	 <200807251904.37302.netdev@axxeo.de> <20080725183622.GA3107@ami.dom.local>
	 <1217013384.4758.5.camel@johannes.berg>
	 <20080725193416.GB3107@ami.dom.local>
	 (sfid-20080725_213320_802558_E914336B)
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-e2sQ7gS5VeqmczjeqMrm"
Cc: Ingo Oeser <netdev@axxeo.de>, David Miller <davem@davemloft.net>,
	peterz@infradead.org, Larry.Finger@lwfinger.net, kaber@trash.net,
	torvalds@linux-foundation.org, akpm@linux-foundation.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	linux-wireless@vger.kernel.org, mingo@redhat.com
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from xc.sipsolutions.net ([83.246.72.84]:48239 "EHLO
	sipsolutions.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751191AbYGYTgu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 25 Jul 2008 15:36:50 -0400
In-Reply-To: <20080725193416.GB3107@ami.dom.local> (sfid-20080725_213320_802558_E914336B)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-e2sQ7gS5VeqmczjeqMrm
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Fri, 2008-07-25 at 21:34 +0200, Jarek Poplawski wrote:

> > Umm, of course it cannot, because then we'd have to take the mutex in
> > the TX path, which we cannot. We cannot have another lock in the TX
> > path, what's so hard to understand about? We need to be able to lock al=
l
> > queues to lock out multiple tx paths at once in some (really) slow path=
s
> > but not have any extra lock overhead for the tx path, especially not a
> > single lock.
>=20
> But this mutex doesn't have to be mutex. And it's not for the tx path,
> only for "service" just like netif_tx_lock(). The fast path needs only
> queue->tx_lock.

No, we need to be able to lock out multiple TX paths at once.

johannes

--=-e2sQ7gS5VeqmczjeqMrm
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Comment: Johannes Berg (powerbook)

iQIcBAABAgAGBQJIiissAAoJEKVg1VMiehFYW8sP/2K5cOt7mAUYh5kg0yNPoC9l
x9gcX638YniIOkHw9zDrIfDfoYa4Z2b2DRXLCF1IdJNVoSGCoI2H9eOyIPUBvn62
6h1jSa007+ejU3+iCGmxajiBxFMAg9ZH8uvUvxAZD7AsCHwq6Ix3R11lBPbxNB8S
O6g827ZdQIxnJvyGEbf1FD58F26q9gH0HflfTVVEMq9TtP7KI4KzNugx3d0T1gko
uEZRS7x6pThCQW5azlA78+Z9eG6o6OLkspOU6RV0lpN9BgleJJMjteFAVF9nMUG6
mj1MdRGfpZBNaxg2iNnYgVaqwb0Xp5llIwcC3SnEcnlieTRlJb15NXJmt+rBmiF7
/geJ6KgT/kODN5Dc5Y6OIDHRdAsb93vcExANzN5tFUpQCFUADXQkbeQVm1LN0fiE
mmf/ZfE/apXyziQ4iXQsQxZnpcGodbiDvpQXbLCCae7r5hTwD0RDi0YM38YwrKiB
BCfzmquREat7Jm5XfLxSOkaaJGjqgMQpe3/pc+uOVQD5icThjSWGazEHi1sFaiL9
3P3eOo3cPmWX4dj08ohG18lU4p+EjnjTzBSfxI2axvNlQb+R9a5EOXzcuECu2KEG
Pa17HJ43YL6+XtkXKkX12s+8C0enLxYc0Q6+kLx7fGMSlCJr7ddixzJx9LWoFcun
vyTR9nUGNr6J+8RHtRrk
=8gfk
-----END PGP SIGNATURE-----

--=-e2sQ7gS5VeqmczjeqMrm--

