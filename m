From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [PATCH] net: Adjust softirq raising in __napi_schedule
Date: Fri, 23 Oct 2009 16:46:31 +0200
Message-ID: <1256309191.12174.51.camel@johannes.local>
References: <4AD31213.6020006@imap.cc> <20091015114052.GA9870@ff.dom.local>
	 <4AD76184.6030900@gmail.com> <4ADF5710.4030505@imap.cc>
	 <20091021211906.GA11401@ami.dom.local>
	 <1256160330.12174.2.camel@johannes.local>
	 <20091021213947.GA12202@ami.dom.local>
	 <1256200021.12174.11.camel@johannes.local>  <4AE1C00B.5010008@imap.cc>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha1"; protocol="application/pgp-signature"; boundary="=-GtZNVJ+WCQlMSt3LTX9e"
Cc: Jarek Poplawski <jarkao2@gmail.com>,
	David Miller <davem@davemloft.net>, hidave.darkstar@gmail.com,
	linux-kernel@vger.kernel.org, tglx@linutronix.de,
	linux-wireless@vger.kernel.org, linux-ppp@vger.kernel.org,
	netdev@vger.kernel.org, paulus@samba.org,
	Michael Buesch <mb@bu3sch.de>,
	Oliver Hartkopp <oliver@hartkopp.net>
To: Tilman Schmidt <tilman@imap.cc>
Return-path: <linux-ppp-owner@vger.kernel.org>
In-Reply-To: <4AE1C00B.5010008@imap.cc>
Sender: linux-ppp-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--=-GtZNVJ+WCQlMSt3LTX9e
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Fri, 2009-10-23 at 16:39 +0200, Tilman Schmidt wrote:

> Strange. Then what are the two separate functions netif_rx() and
> netif_rx_ni() for?

netif_rx_ni() disables preemption.

> > This really should be obvious. You're fixing the warning at the source
> > of the warning, rather than the source of the problem.
>=20
> Good idea. So please do tell us where the source of the problem is.

You use netif_rx_ni() instead of netif_rx() at whatever place that
causes this problem.

johannes

--=-GtZNVJ+WCQlMSt3LTX9e
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----

iQIcBAABAgAGBQJK4cHEAAoJEODzc/N7+QmaStYQAK+3IL2OlaRETBYjrgvNL4zi
rKCKbYSxUYdNmwIn9ldy/eXm37pYN/wNVY7CeoVzfNeS3nxXMhKd7D/hetFtK7n9
JGjlf+6kY8el0k/6PCEVdarfvIujHJXADdVnG10LZoLb3YSM2wSeIPvPfoSb10XS
Jf+8azFy0Arg2nqRJLflslV3y2YnD9fGDb9uLmcIP2/PPBbmkkz9j7Nm4saM0TNj
06ugJpg8aJawsuLr3K1IlPCucTIiDxhU9e/d4zwZYJxHJpsikMYQkuA+tqTSTmBo
bW8iNHzNWfb1SkMkkKBbvau0Nb9mANDciLVt9T9r+e9ccTB1hqfRY51NCB2lwNOF
BFhpr1fRqZ40DouMp7umzbRvR8dyljl8Hvs1NGOJwY1xGVyOMsKMr63EbSN6BiWM
bCPKpnFbXfOFjevctO2D3Dk058WhTGXgmW3choBpCxCZRwS89zrlkMO/evjxx3Yg
D/jlHlHo8u4AIaGAQcDmDifXBCoihnx9+N2Sbt/OKnmexLmY7EvEpgXfNCgj+eKB
KI0vd0Xl/ayjQ8nreS9bD4Oco9g528izVHxvUPI+OUyE0VqZee/TjvAkZ4psSaKg
x1JzBsTZGxALQxPcQ4UbSBxkFYZLrWkToJ8aVegQnsPl4ijzke3q0S1VaHpfHawi
8znqqSJ/No+Hf2EoXX/D
=Xf17
-----END PGP SIGNATURE-----

--=-GtZNVJ+WCQlMSt3LTX9e--

