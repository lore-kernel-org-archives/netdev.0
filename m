From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: mac80211 truesize bugs
Date: Sun, 04 May 2008 13:25:55 +0200
Message-ID: <1209900355.6210.64.camel@johannes.berg>
References: <1209815533.3987.21.camel@johannes.berg>
	 <20080503.180300.10562559.davem@davemloft.net>
	 <1209865354.6210.23.camel@johannes.berg>
	 <20080504020203.GA30514@gondor.apana.org.au>
	 <1209866916.6210.39.camel@johannes.berg>
	 <20080504021213.GA30660@gondor.apana.org.au>
	 <1209867740.6210.46.camel@johannes.berg>
	 <20080504031652.GA30993@gondor.apana.org.au>
	 <1209890847.6210.51.camel@johannes.berg>
	 <1209892489.6210.56.camel@johannes.berg>
	 <20080504094444.GA541@gondor.apana.org.au>
	 <1209894754.6210.58.camel@johannes.berg>
	 (sfid-20080504_115215_663728_A338AE69)
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-49r3pBiJBo59BU3q9l5k"
Cc: David Miller <davem@davemloft.net>, mb@bu3sch.de,
	netdev@vger.kernel.org, linux-wireless@vger.kernel.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from xc.sipsolutions.net ([83.246.72.84]:33676 "EHLO
	sipsolutions.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753848AbYEDL0J (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 4 May 2008 07:26:09 -0400
In-Reply-To: <1209894754.6210.58.camel@johannes.berg> (sfid-20080504_115215_663728_A338AE69)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-49r3pBiJBo59BU3q9l5k
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Sun, 2008-05-04 at 11:52 +0200, Johannes Berg wrote:
> On Sun, 2008-05-04 at 17:44 +0800, Herbert Xu wrote:
> > On Sun, May 04, 2008 at 11:14:49AM +0200, Johannes Berg wrote:
> > >
> > > I just re-did the test, and I definitely need 29 more bytes on, for
> > > example, the IPv6 autodiscovery packets and ICMP packets generated wi=
th
> > > ping(8). Some of them even need additional tailroom.
> >=20
> > Could you find out the code path that created the skb in the
> > kernel so we can see why there isn't enough head room?
>=20
> Yeah I was just considering putting a stacktrace into the skb when it's
> allocated. Haven't done, lunchtime now.

http://johannes.sipsolutions.net/patches/kernel/all/2008-05-04-11%3a23/027-=
skb-alloc-stackdump.patch

will report results after kernel rebuild.

johannes

--=-49r3pBiJBo59BU3q9l5k
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Comment: Johannes Berg (powerbook)

iQIVAwUASB2dQqVg1VMiehFYAQIs5w//QlyamBWLEsq6DxEhFwDR1kp83HqLUfto
p8m3HXcu4icBLFjQSEwXpyYfijYRPsyDIiS8NZZK48JzTMjNuNwcvIhuhERER7Y4
Y5I2AbVtMBQ6bzq5dZcQt9RNntm/4hz7u40ID5rqANAvXVFdRXNKoiAi2hS8kjTq
0//MMvVhWq8UKySJoeqCbf6BU/lYwY3tR1RtXRyjWpGYAbrNTMnEcJIChbTYOFGL
wLhJe781vxOLowpVzbwYyIkhPrKjLTcsGuYWEoE1N87vVrDvreBAi/97AcRxe1w5
NUXdjTpAzEPdNHGB5vwd8X/utKB2ehwQUB8n1T/aud+UhPN9KjkCrIs0/qG5ywzz
me6DPxzbW0ClXQ2Ttc7DG7+dhtZfQnSVHLH/Ops9cURr0SwpKZhSr5UudvYvFgv7
3bFhieaK/4r6ftYBFFPrqzz1rvvEucC9Q20YsCW6m5VwaO2lV9wDvQCSwCBzfCpz
x0kV7V2Hd9E2A0DuCs3vD93om02wzxiNHGihf7J2IWN/+0quhyKcw5qqAfc2xcfX
skKg4BHl8wcoI7bY9EumysZMbArTEAkXu8JwNMJbC0NUiJCAVsFo8bpYuJESKnHn
trxo2/xZTLyVyHT77iA/YnOenBUz13COmx4wsqipS0CeXi3vf8D5ar7nOgB7gc6R
bt852nvkAUQ=
=3E9m
-----END PGP SIGNATURE-----

--=-49r3pBiJBo59BU3q9l5k--

