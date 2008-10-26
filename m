From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [PATCH] add %pM printf format specifier
Date: Sun, 26 Oct 2008 20:40:15 +0100
Message-ID: <1225050015.3746.2.camel@johannes.berg>
References: <1224892008.3919.27.camel@johannes.berg>
	 <49035AF0.6040700@anduras.de> <1225008096.3478.3.camel@johannes.berg>
	 <20081026.010329.11475786.davem@davemloft.net>
	 <1225009308.3478.22.camel@johannes.berg>
	 <1225009822.3478.30.camel@johannes.berg>  <1225047674.10060.10.camel@brick>
	 (sfid-20081026_200122_320043_BFBB81CD)  <1225049591.3746.0.camel@johannes.berg>
	 <1225049929.10060.11.camel@brick> (sfid-20081026_203902_019881_0F8064FC)
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-iCvscDnWIxyc6GSkPXSM"
Cc: David Miller <davem@davemloft.net>, anders@anduras.de,
	netdev@vger.kernel.org
To: Harvey Harrison <harvey.harrison@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from xc.sipsolutions.net ([83.246.72.84]:53530 "EHLO
	sipsolutions.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753663AbYJZTkW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 26 Oct 2008 15:40:22 -0400
In-Reply-To: <1225049929.10060.11.camel@brick> (sfid-20081026_203902_019881_0F8064FC)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-iCvscDnWIxyc6GSkPXSM
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Sun, 2008-10-26 at 12:38 -0700, Harvey Harrison wrote:
> On Sun, 2008-10-26 at 20:33 +0100, Johannes Berg wrote:
> > On Sun, 2008-10-26 at 12:01 -0700, Harvey Harrison wrote:
> > > On Sun, 2008-10-26 at 09:30 +0100, Johannes Berg wrote:
> > > > static char *ip6_string(char *buf, char *end, be16 *addr, int field=
_width, int precision, int flags)
> > > > {
> > > > 	char ip6[8*5];
> > > > 	char *p =3D ip6;
> > > > 	int i;
> > > > 	u16 tmp;
> > > >=20
> > > > 	for (i=3D0; i<7; i++) {
> > > > 		tmp =3D cpu_to_le16(addr[i]);
> > >=20
> > > 		tmp =3D be16_to_cpup(addr + i);
> > >=20
> > > > 		p =3D pack_hex_byte(p, tmp >> 8);
> > > > 		p =3D pack_hex_byte(p, tmp & 0xFF);
> > > > 		if (!(flags & SPECIAL))
> > > > 			*p++ =3D ':';
> > > > 	}
> > > > 	tmp =3D cpu_to_le16(addr[7]);
> > >=20
> > > 	tmp =3D be16_to_cpup(addr + 7);
> > >=20
> > > Or maybe just cast addr to char * and avoid the byteswapping altogeth=
er.
> >=20
> > Yeah, this was obviously not tested. Want to build it? I don't have
> > access to a fast build machine right now.
> >=20
>=20
> Could you send me whatever you've got currently and I'll have a go at
> it.

I don't have anything. I typed this into the email directly.

johannes

--=-iCvscDnWIxyc6GSkPXSM
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Comment: Johannes Berg (powerbook)

iQIcBAABAgAGBQJJBMecAAoJEKVg1VMiehFY9ZEP/2lqGrM+xbhagMJuYUTbUuJB
UTQ2xw17rO4WE//qEm1BV6k3YbcISzhESIAVEfgi3Hu2rlkEiht+pEVkCDla00MP
rBORsXWFZUbpi2kWSuT1jsTHiG9+DvWfg0q78M51Ly3ROF2SU49uE3tpRsXbebkK
e0YtgXFayKMoHdP5VAvtIOorB4/nsyMKHsS3B70s6OrbJuGr5aCJOp50syduIbsy
BMMeUx5Q0BH+7PUMvqwaj9GO/VPagmJkPNHO5DIid/15wRyswWvAao1gRezcwnqU
SSWaLVYoSzTBNEJ/LfMz54E1fnC+fagvoWNM/R3nceqM8eQW+QXVXKbnSM5xbOnQ
+x8petsC/4lIOJ8VyvDiVlpYrupP4IJeoSJS3ZrJ+s9O1KyS60T2Cb12RegNziTL
uayvv+dS9RQKKrIiMKrxTKh4wxhSJ6veNu3zjLwI/s2lzfkj8D8TvTHETdJwqdwJ
td5XHmmbJD/Txl5uvy5NJjTGhp4Q3VMbpIyTYyEuOXY9iAh32QC9imILFYGiIUb9
18IL7uwRrkc1oj+2aTxADtXYCWOpYfa6bVuPJqkcAegPH4MbrNXr5p9IFDbnYEUk
S/MhK+1PHW6OTA5RbsSF5jYQu0XASOOYDwfdTQPsmDYGUFCqhrGV2c6B6iN32uyK
s5oVpUdegm/unt50kwei
=m0P/
-----END PGP SIGNATURE-----

--=-iCvscDnWIxyc6GSkPXSM--

