From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [RFC v2] mac80211: assign needed_headroom/tailroom for netdevs
Date: Mon, 05 May 2008 22:10:14 +0200
Message-ID: <1210018214.4181.27.camel@johannes.berg>
References: <1210014316.4181.14.camel@johannes.berg>
	 <20080505.125013.129139559.davem@davemloft.net>
	 <1210017456.4181.23.camel@johannes.berg>
	 <20080505.130225.159803012.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-ZTs7XAeDZZT35+d9sBNl"
Cc: tomasw@gmail.com, linville@tuxdriver.com, netdev@vger.kernel.org,
	linux-wireless@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from xc.sipsolutions.net ([83.246.72.84]:52702 "EHLO
	sipsolutions.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759638AbYEEULL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 May 2008 16:11:11 -0400
In-Reply-To: <20080505.130225.159803012.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-ZTs7XAeDZZT35+d9sBNl
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable


> And the copy is necessary because you need more tailroom or something?
>=20
> I don't understand why simply having all the space you need is not
> better and faster :-)
>=20
> Even if you have a clone, you can muck with the data in the IP and TCP
> header areas, so long as skb_header_cloned() is false.

I think it's probably all because I don't understand skb_cloned() vs.
skb_header_cloned() and mac80211 came with checks for skb_cloned() that
I didn't spot.

So you're saying the check there to see if we can add 802.11 headers
should depend on skb_header_cloned() and not skb_cloned()?

> So I can only conclude that your problematic case is that of
> encryption, right?  That's the only situation where I can imagine you
> need to modify with packet data outside of the protocol headers.

When is protocol header equivalent to skb header and when not?

johannes

--=-ZTs7XAeDZZT35+d9sBNl
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Comment: Johannes Berg (powerbook)

iQIVAwUASB9ppaVg1VMiehFYAQKrRg/7Bb7CD0xyv81194rsV4HdhdM3bSlelN6D
XkXYgvWh5/WZwQKWUvzDd0VW+uOOAsPU578KXyGmNjH7XQRHT78DvAgppbxXi2Mb
acyb4gDM7/FZSBCyrHcdEIZKvRJa5wwt9LSmWMoS7FDxkXkKj8ABmLsc7fiudY99
YkGFcUe4n+ZsMKVwPQuFnLparqFVW4C3RHi08dwj4jPLTuxgZGxyEx7pJArze0Od
NmVZTvamTSTiOsmu7mKRyoICqW7/gtZLX8dt8JAqO3Nw6wxDeknGF7oK371aYLOH
WdJRe8a8VKcs/KC7C3ApfBbvGua0Il2w0KDaHnTQnMz0r1tzkjLm7JMbHDrvC/HP
ByxosYF1+P0cBeeaB1adO+XlUm3m6nTrXlkQxeKqltt3LKCh7spByLuI4ZL59/sG
Rd2v1eIUDDKoEg7B7T9DEF1XAyVMQOBWsxia/033OG409NQK+6qAre0tIq1ssXI4
LW7y5Omy2acVFxornWSBHhmUuk3Go76Qa3Qj6EjJhElrpkX9tYF6uL2/h4pGG1I6
SbFkeWjYwlhipiSqPgqQZprZqGz7A0x1WQSJyUepOR2DMd7BTUEV2Wf0ZoeozWnK
yDv8k97LcyzPTJuZABB1CdgScBEe23CxYvaKWwUeS9H1AFIRiHXgylAzqIoQe4W2
uEOyVnIskGM=
=LeRX
-----END PGP SIGNATURE-----

--=-ZTs7XAeDZZT35+d9sBNl--

