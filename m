From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: TXQ real_num_tx_queues comments/questions
Date: Tue, 15 Jul 2008 11:25:23 +0200
Message-ID: <1216113923.3535.14.camel@johannes.berg>
References: <1215769627.3483.107.camel@johannes.berg>
	 <20080715.021637.103260952.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-aZOo7ZmERGRAmIPS4DS2"
Cc: netdev@vger.kernel.org, linux-wireless@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from xc.sipsolutions.net ([83.246.72.84]:43564 "EHLO
	sipsolutions.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751809AbYGOJZY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Jul 2008 05:25:24 -0400
In-Reply-To: <20080715.021637.103260952.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-aZOo7ZmERGRAmIPS4DS2
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable


[...]

> > I like the RCU variant better, as it means we don't need a "central"
> > lock that is taken for all tx queues, and it also allows other drivers
> > to actually change real_num_tx_queues in a similar fashion, should that
> > ever be required.
>=20
> It seems to me that a simple synchronize_net() call near the end of
> agg queue removal would solve your problem as-is, wouldn't it?

Well, as far as I can tell we can't do that there because it's in
tasklet context/called under spinlocks so it has to be atomic. I think.

johannes

--=-aZOo7ZmERGRAmIPS4DS2
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Comment: Johannes Berg (powerbook)

iQIcBAABAgAGBQJIfGz7AAoJEKVg1VMiehFYyrAQAJ+hOOeozVa1RzNlvPrIzLiK
a3Yj4ivHpc8d3crnL3kdBAyilMaw6rQLRmHWgCScvgJXPY1zKrgYU4G5R1J1KgdB
pORycYDc81v+Ts132Dq1H+Ji2yAhBIQI4dyyzlmMsCW6jp5tfQEe1DyI9JTpIYEZ
gApXgUBwQXb1VOnExfP6HKaNUnydC9CK1NM8ksWIa/w+/GB0AQSUDuSVktgq9WF1
6YTCEPaYBTdrtgvm9+l0NyCC/ywNbTQbQXeeapgx+CiOhT8HxpKwq+OmXCHhjOS8
Gea4AzXjnEVBFzS/ZqMGakL0y3snY9VpJ02tJtuE5gAjJRV1k+LX/Z49Wujx7jlH
75j80grwcxpS6Pxz7tQt7pljw8EOSrxt6vx+BLKrzgGaH+7/fRR+MTmP35ZuUj1z
LF2lLHAZaFq9rcZmL9BRhPUtE6zUGEn7qD/qpKmffT5U+t0mY/lW3yoG6DbntVrR
tt19PAGtn/FFPeroo8INbR3eZPztS7+9Ej0L+/15l3kl6beNUMEAudtMpCnt3mO3
fpZUMGVgwMlIl9U8flg+WcpTETZSe7j+lpr21FdVIXpH2iJPrp6w3OUoQq88mL7j
x59rZ5Fpn7GCGs7y3TkpqiN9ZHLzfg6ANhBBU/Z/Loa19kWwsAiaDJYISiKgxxEw
PfK/QwkpfpKXafMcRdlG
=rYvc
-----END PGP SIGNATURE-----

--=-aZOo7ZmERGRAmIPS4DS2--

