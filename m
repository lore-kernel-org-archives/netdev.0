From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [RFC PATCHv3] printk: add %pM format specifier for MAC
	addresses
Date: Tue, 28 Oct 2008 09:04:51 +0100
Message-ID: <1225181091.3796.69.camel@johannes.berg>
References: <1225124904.5440.1.camel@brick>
	 <20081027.123805.134354592.davem@davemloft.net>
	 <1225137542.5396.10.camel@brick>
	 <20081027.154736.178482850.davem@davemloft.net>
	 <1225149254.6339.4.camel@brick>  <1225151305.5269.105.camel@localhost>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-BC8mBCzcgqcogHZpMcIm"
Cc: Harvey Harrison <harvey.harrison@gmail.com>,
	David Miller <davem@davemloft.net>, anders@anduras.de,
	netdev@vger.kernel.org, akpm@linux-foundation.org,
	linux-kernel@vger.kernel.org
To: Joe Perches <joe@perches.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1752927AbYJ1IFU@vger.kernel.org>
In-Reply-To: <1225151305.5269.105.camel@localhost>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--=-BC8mBCzcgqcogHZpMcIm
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Mon, 2008-10-27 at 16:48 -0700, Joe Perches wrote:
> On Mon, 2008-10-27 at 16:14 -0700, Harvey Harrison wrote:
> > I was thinking of using %pI6 to replace NIP6() and NIP6_FMT and using
> > %#pI6 for NIP6_SEQFMT.
> >=20
> > On the IPv4 side, maybe use %pI4 for network endian NIPQUAD() and NIPQU=
AD_FMT
> > and then %#pI4 for host-endian HIQUAD(), as displaying the IPv4 address=
 without
> > the periods isn't useful?
>=20
> HIPQUAD is horrible and should disappear.
> Just use htonl first.

But you can't really say

printk("... %p4 ...", &htonl(host_ip4));

can you? I suppose the compiler would actually create a variable for
that?

johannes

--=-BC8mBCzcgqcogHZpMcIm
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Comment: Johannes Berg (powerbook)

iQIcBAABAgAGBQJJBsefAAoJEKVg1VMiehFYZ64QAK5IiW/DdebL5lEeh1TsXB4k
96RhdNby57/j7zTvj6rtjwgUCgv5a4yyRXc7u5iTetyx8SNk0x2p8kBxqvCY2RxU
+oq4xPiT2vTNN0eOUGln6pboAg2DS4/PQvvV42lVPD9jeNjbXM0hzz80GPTaADbo
l78etzVaiBVeaYZeZhzVUq1eGoh3BSUFQ2xjjGSt4iqiSKybelOF60Sqta6eAQU1
MeX5mVV48XhhUCRhqMMivF1yYaruv5SVnpvAhnvOY/qNB6VkxXBNYYs+W/rmObXi
v1wSSlcpGfXr+Q/3h70GfQnrbz6Fm0cFwFQvQXGCUDrG71tirq5ueG8aDjQpaA7r
dW1ymDHEH0KBHU8R8+qVS39FFUIsTei4p417Z4BEANTWqB/yF0hytvdxorZesUa9
oumAgafmSAgyNA9VN9jqjUlfVzVySVym5dbds/o6l6r09FeQTBdR/lhLXI4JxpJ+
vfJ/E/hpM6o3Dtz5q5u1iBVhVy6VLnQ++AioHnR09cTWGMc9CyBvjdy2nEAhVByb
AXH/EZKVs6G/89kC3UEyFHhF6OG4tl98T32zL5+11K8L+zH5BEhoAiozrvrS06Qg
4RQDyIH2A8JiVvTHs7RvkbZdDnR00kxt+h/3wcyp00X2oO2iGN4OSzsk/VwOs67i
rimenRp+fglXPmg0QGid
=cl+w
-----END PGP SIGNATURE-----

--=-BC8mBCzcgqcogHZpMcIm--
