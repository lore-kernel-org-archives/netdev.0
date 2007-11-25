From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: wireless vs. alignment requirements
Date: Sun, 25 Nov 2007 18:04:17 +0100
Message-ID: <1196010257.4149.234.camel@johannes.berg>
References: <E1IvoID-0006aR-00@gondolin.me.apana.org.au>
	 <1195893216.4149.186.camel@johannes.berg>
	 <20071124133200.GA27531@gondor.apana.org.au>
	 <1195912176.4149.194.camel@johannes.berg>
	 <20071124141319.GA27819@gondor.apana.org.au>
	 <1195938799.4149.197.camel@johannes.berg>
	 <20071125014446.GA32104@gondor.apana.org.au>
	 <1195988428.4149.225.camel@johannes.berg>
	 <20071125112251.GA10039@gondor.apana.org.au>
	 <1195998864.4149.229.camel@johannes.berg>
	 <20071125140121.GA12665@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-x97m9NRiaMTqgg2izU1L"
Cc: dsd@gentoo.org, davem@davemloft.net, netdev@vger.kernel.org,
	linux-wireless@vger.kernel.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from crystal.sipsolutions.net ([195.210.38.204]:57343 "EHLO
	sipsolutions.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752273AbXKYREm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 25 Nov 2007 12:04:42 -0500
In-Reply-To: <20071125140121.GA12665@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--=-x97m9NRiaMTqgg2izU1L
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable


> > Hmm. I don't think so. Take an AP for example. It gets a lot of packets
> > from stations. Now, if you're not QoS capable then all is well. But i
> > you are and some stations are as well then all those stations send QoS
> > packets (+2 bytes). Or take an AP connected via wireless (WPS), WPS has
> > +6 bytes so I get all incoming upstream traffic with such unaligned
> > headers.
>=20
> The question is does this actually change all the time.  Let's
> say you took a random sample of a second worth of IP packets
> over wireless, what proportion of them are going to have the
> same hardware header length modulo 4?

I'd think that totally depends on the traffic. If you have a non-QoS AP
with WPS upstream connection, then the traffic to stations will be
four-byte aligned while the WPS upstream will be at a 2-byte-mod-4
boundary. And you'll have all packets from stations come in aligned and
all response packets from wherever come in as WPS.

johannes

--=-x97m9NRiaMTqgg2izU1L
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Comment: Johannes Berg (powerbook)

iQIVAwUAR0mrEKVg1VMiehFYAQIFAA//UXB0E0PGaYxne15/l4wYiHE6+pQyTQtV
t57rgJBwPgN18l/PmWCn5EMv+0h0DlF1MRMA3dUusUy4b7MVoUdVF1YX8qoEtfEI
UP/whJNH6nYzZGH0bpiQSCi3CQ+kvb1NEkkxotxPDc50TEkQNHoNYKhbK+pD2zCn
ll2aIAOVtse9EyXNOeM6qe35EisS+GSP5R1oDX2aHUAkJMRly6lO0AtFjVI2LuWu
PcUHkSOH1H6Ow5Tj99yvMM1/GJKOh5AUJAwhgIGdGRfDmdsMVAdhUaWbJE19uVJE
y7GuwGsreBewoE2DcicQ6asY4f3a9cOy4L5SnxxOJRjH9wNw7/L347Zi2fmlBFvX
PL0+VvkvznlERe3tEe/yzn0/SbTzYViNQrNfgYzgWThu1dwU2y9hRau4fuTufS0p
aHDDIinfQfsr5+Ss4NiAAjC4YsOshRbh5FEQUNLPG96gG0Gyyu/0lgrZjZjQYOZA
OYGC0DiKZ63Z0daVSDbzVv7BnTUt4EN6DzEZiFhrGl00G1Oyx0sqbacH5wzn7zzG
WjAh3cZGoX5WJObEmRxYcpm4mIoReyKh0rOFX9z/Ubt2n1xLYKeR2abOTKGPGuJg
pY0YppdHhxP8MfSopIzzExQmQl3311h3wfRc81txXhNrEZFBDg1goauODT2v3gPL
k8SBopTpMcI=
=T5Up
-----END PGP SIGNATURE-----

--=-x97m9NRiaMTqgg2izU1L--

