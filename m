From: Antonio Quartulli <antonio@open-mesh.com>
Subject: Re: [PATCH net] bridge: clean the nf_bridge status when forwarding
 the skb
Date: Thu, 17 Oct 2013 13:37:35 +0200
Message-ID: <20131017113735.GB2699@open-mesh.com>
References: <1381791096-3561-1-git-send-email-antonio@meshcoding.com>
 <20131017112857.GA11318@localhost>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
	protocol="application/pgp-signature"; boundary="adJ1OR3c6QgCpb/j"
Cc: Antonio Quartulli <antonio@meshcoding.com>,
	"David S. Miller" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Stephen Hemminger <stephen@networkplumber.org>
To: Pablo Neira Ayuso <pablo@netfilter.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp03.online.nl ([194.134.41.33]:57797 "EHLO smtp03.online.nl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753373Ab3JQLiG (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 17 Oct 2013 07:38:06 -0400
Content-Disposition: inline
In-Reply-To: <20131017112857.GA11318@localhost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--adJ1OR3c6QgCpb/j
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Thu, Oct 17, 2013 at 04:28:57AM -0700, Pablo Neira Ayuso wrote:
> Hi,
> > +
> > +/**
> > + * br_netfilter_skb_free - clean the NF bridge data in an skb
> > + * @skb: the skb which the data to free belongs to
> > + */
> > +void br_netfilter_skb_free(struct sk_buff *skb)
> > +{
> > +	nf_bridge_put(skb->nf_bridge);
> > +	skb->nf_bridge =3D NULL;
> > +}
>=20
> This should be nf_reset.

You think I should directly use nf_reset instead of this function?

I see that nf_reset() cleans up the conntrack part too: does it also become
useless once the packet exits the bridge interface?


Cheers,

--=20
Antonio Quartulli

--adJ1OR3c6QgCpb/j
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.22 (GNU/Linux)

iQIcBAEBCAAGBQJSX8v/AAoJEADl0hg6qKeOM5IP/1uMmClPNi0SxlmN2Agin3/r
Oa8ElHRwP6C0AxtdQickUVTai0y/LqEE0JHkUPBGGn8uWjpAay10cvCYvqbrAzpO
Mkgbn4XfSHm8U8DWwZ0n+KsIBAjP4/9MCL9dqlN7LZ6rmB7ryZg3v1SqN5PobbNX
PQx0nqYJrjmcqfi0eRQVESM8i+8uZigdbINrxVo6SYmVFb48rsqp9IG+vWdbqyNx
7DQQ1QlTCF1w5oaGx8qv6bkrtpHUFim80ZwTQGby29ytv3LQSeTxvSryVuuQHDh9
R5JXFESzx4CBVscMh571BUakMVOnacv4akzc5wOa/RQqfrETP7ynld8hua+VnhGB
Cevtq40Sm+wR68O/lJabiNnz1GoITxDTGuy1tQpQhH5NDKB0KCmeXa+c3d8dO+5S
4JN1Eiht3jXslfmGwPQpCD/2NhW0Y7RD+BGipomo+kl0tc3EFcySEd+9HWf/DDYU
jo4C111V7bzXM4iBlC/l/0eYBTQh3cR2tjSZTNBj604foBTw77eYev8X6MYDjBt2
UOyAUHmMIBjUJKfnssqw+OBwD2md0AHM1dSjHkIVF0eG6rxcpSIVbig8+Hr+2YG0
IbGZGK1Ut6sEO9R62v9T8u8ZSNoiej9BD7EAH6mtopffQz8vs9P14XZldynuB8r7
X1hxmVnUkXP1iwroIrXG
=HGkD
-----END PGP SIGNATURE-----

--adJ1OR3c6QgCpb/j--
