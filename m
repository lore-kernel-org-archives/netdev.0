From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: Kernel WARNING: at net/core/dev.c:1330
	__netif_schedule+0x2c/0x98()
Date: Fri, 25 Jul 2008 21:16:24 +0200
Message-ID: <1217013384.4758.5.camel@johannes.berg>
References: <1216806614.7257.152.camel@twins>
	 <1216810696.7257.175.camel@twins>
	 <20080723.131441.200166513.davem@davemloft.net>
	 <200807251904.37302.netdev@axxeo.de>  <20080725183622.GA3107@ami.dom.local>
	 (sfid-20080725_203602_626786_F66C7AF2)
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-pVCCsOfpIeDJt6eU6WLf"
Cc: Ingo Oeser <netdev@axxeo.de>, David Miller <davem@davemloft.net>,
	peterz@infradead.org, Larry.Finger@lwfinger.net, kaber@trash.net,
	torvalds@linux-foundation.org, akpm@linux-foundation.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	linux-wireless@vger.kernel.org, mingo@redhat.com
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from xc.sipsolutions.net ([83.246.72.84]:45788 "EHLO
	sipsolutions.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755170AbYGYTRM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 25 Jul 2008 15:17:12 -0400
In-Reply-To: <20080725183622.GA3107@ami.dom.local> (sfid-20080725_203602_626786_F66C7AF2)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-pVCCsOfpIeDJt6eU6WLf
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Fri, 2008-07-25 at 20:36 +0200, Jarek Poplawski wrote:
> On Fri, Jul 25, 2008 at 07:04:36PM +0200, Ingo Oeser wrote:
> ...
> > I'm sure as hell, I miss sth. but can't it be done by this pseudo-code:
>=20
> ...And I really doubt it can't be done like this.

Umm, of course it cannot, because then we'd have to take the mutex in
the TX path, which we cannot. We cannot have another lock in the TX
path, what's so hard to understand about? We need to be able to lock all
queues to lock out multiple tx paths at once in some (really) slow paths
but not have any extra lock overhead for the tx path, especially not a
single lock.

johannes

--=-pVCCsOfpIeDJt6eU6WLf
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Comment: Johannes Berg (powerbook)

iQIcBAABAgAGBQJIiiaFAAoJEKVg1VMiehFYvkAP/0z708i0JT8taivKX4WwMk1a
VfLcG2FS/EaXdtFpAZfBkVS5BI3X75E+0tK3KHyBqn+9kuH2g1fxla6YSf/dRK7j
wTXJU6uQYKxVGthG409YmraEqU44AypRT7jnNEk9met7VVQGZTrBkYrh8A+ZhVuL
S0Uc4yvKbGAnpMs4hYdhgon9NPaCvExEBqb7I1N/wH7HuqntWviN17QkCPJhG7iu
IN/j5ML2t/7t9HFp//qQq5LQABEvkRfjYKndhdmmKpEnMnzKa2XYdVLazHhT1Lpp
xqTKtjxSvET17qJ/WhljOYq7NB5qZIama1LigvzH6MZOGbRT9AeWwhUv2u3NU7DG
yw0F6Ep7650PT5Z08n8HBsOF1w+kuMdlDzajAzlAYAWtXoMQx8IXZR2SlAPM1WWv
s6TwmiC0kS5c/R9RBOmHj5qR+Px1GjjOR1LrjL+ZXZj0cT4Evmb428KK+bXU9y3Q
XAn1kbixEbEA9MoMztOl440XAmLf1BeHOXhxXdqbc291/W5XOY9Ad/6HyIbkSgGn
2vZAgMp4T53x9vh8qZx1wrj5nRIIttMor/jwL9ilwAvJHYmY6IDMIK6rEQw5AZCN
x1KOSbEz9WWEYSKWaoemYsxbBeihNfsbBeW1tOCQn/6iRb5mTo0k4lwXbqWhEeSu
dl+MkMp12Ab+IuLcox6d
=EPkt
-----END PGP SIGNATURE-----

--=-pVCCsOfpIeDJt6eU6WLf--

