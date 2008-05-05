From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [RFC v2] mac80211: assign needed_headroom/tailroom for netdevs
Date: Mon, 05 May 2008 19:57:34 +0200
Message-ID: <1210010254.4181.4.camel@johannes.berg>
References: <1209936253.7304.10.camel@johannes.berg>
	 <1209936745.7304.16.camel@johannes.berg>
	 <20080504.173051.133197507.davem@davemloft.net>
	 <1209972139.3655.9.camel@johannes.berg>
	 <1ba2fa240805050727r2060b0b4x3a9b3240647b66b1@mail.gmail.com>
	 <1210000923.8245.26.camel@johannes.berg>
	 <1ba2fa240805051015t7dfd3bd2nf7bc2fc1ab9799ca@mail.gmail.com>
	 (sfid-20080505_191442_671116_FFB94097)
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-BGorA4iwPX8fchrbzD/q"
Cc: David Miller <davem@davemloft.net>, linville@tuxdriver.com,
	netdev@vger.kernel.org, linux-wireless@vger.kernel.org
To: Tomas Winkler <tomasw@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from xc.sipsolutions.net ([83.246.72.84]:38273 "EHLO
	sipsolutions.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751125AbYEER63 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 May 2008 13:58:29 -0400
In-Reply-To: <1ba2fa240805051015t7dfd3bd2nf7bc2fc1ab9799ca@mail.gmail.com> (sfid-20080505_191442_671116_FFB94097)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-BGorA4iwPX8fchrbzD/q
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable


> I would set  NETIF_F_SG OR FRAGLIS to features...?  (What actually is
> the difference?)

Do you support TCP checksumming in hardware? -> no SG

NETIF_F_FRAGLIST I haven't understood, but it seems to apply mostly for
IP fragmentation?

> but even when it does I
> >  don't see what we can do unless we want to do all this inside mac80211
> >  which I'd rather not.
>=20
> Like Sending mac80211 header OOB as xmit function argument?  This will
> probably affect all the wme code as well...
> Not good.

Yep.

> Isn't this a requirement that header fits into a continuous buffer ?

which header? The SKB header (skb->data .. skb->tail
(skb->head..skb->end)) or the 802.11/device header?

> It's sounds strange to me that there is no solution for efficient
> bridging... Can bridging code handle this if we have native interface?

I don't think so, but I'm not sure.

johannes

--=-BGorA4iwPX8fchrbzD/q
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Comment: Johannes Berg (powerbook)

iQIVAwUASB9KjKVg1VMiehFYAQLDhhAAxcv2mWWb1tdm6QEev54NGNr8xXIn1jlC
Ggc71zCD4kZRxBsLn6+fD0gxqYVxMWb+61X+dQyK34YR+lSpnJARqNtlz3uceyUU
461KqPsAQSu0ZShCDtk2xu6DNqBfjz6s/3V6ccDho/fmuMTHmtbIESpmxgBUJHlV
hYjV/Lnattiz4IMCPF7FGwla5zOB/0xI6msbjSDDKU0npmyJO6SWuesmpIXaKUKS
OKuKKFYqJ1gqhDApYuy0mH7tWDgBIaPyOxpIxyOcMQJ3iP+1DU/lrSvAn84YItxZ
IocI87KEk3RCtKm+uTwj7C6ZHo36xwqwt4O77i5kKBuawmIuMM4GWvBGBBPBmpIj
kyryxQ2eoSKjSLustXM0BihKWkwjmpMTyzZXp1SCeyAJerW/pTF6V6/ESBKt8hpa
1xIhoGvqkVPYjixio40rUmkV6Z2s3ARCdJ3R/yPmzXG4DixgBDJLKKVz5Einu4EB
KE0YcFzU1uZtlekcna180VC3Sv70DxZE2boEyQc4dfY1tVzlPN8gRd510z+BvQu4
n7vpa5N2gpNTuzEBApahxksDV/gQFhD6JseV0RqUAuio/qdNcdzJJ+4ca4vEO2Zk
jyrN7vRqLJY05YUcDf1DhQXUv8gXZe3QTIKBCSALm4gNi5tpSwyDq5GchGJwmdUd
Dkhij3y4NIs=
=lZAD
-----END PGP SIGNATURE-----

--=-BGorA4iwPX8fchrbzD/q--

