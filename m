From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [PATCH/RFC v3] introduce ARCH_CAN_UNALIGNED_ACCESS Kconfig
	symbol
Date: Thu, 20 Mar 2008 20:12:03 +0100
Message-ID: <1206040323.16475.155.camel@johannes.berg>
References: <1206023695.16475.137.camel@johannes.berg>
	 <20080320181310.GA17884@uranus.ravnborg.org>
	 <1206038373.16475.150.camel@johannes.berg>
	 (sfid-20080320_184016_333600_B74BDE6D)  <1206038734.16475.153.camel@johannes.berg>
	 <1206040151.17059.10.camel@brick> (sfid-20080320_190919_345083_ADEC461D)
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-F6/Ia8Jp6T+uxIw2Ii5u"
Cc: Sam Ravnborg <sam@ravnborg.org>, Daniel Drake <dsd@gentoo.org>,
	Linux Kernel list <linux-kernel@vger.kernel.org>,
	linux-wireless <linux-wireless@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>
To: Harvey Harrison <harvey.harrison@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from crystal.sipsolutions.net ([195.210.38.204]:34703 "EHLO
	sipsolutions.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756647AbYCTTMX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Mar 2008 15:12:23 -0400
In-Reply-To: <1206040151.17059.10.camel@brick> (sfid-20080320_190919_345083_ADEC461D)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-F6/Ia8Jp6T+uxIw2Ii5u
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

> > +#ifdef CONFIG_HAVE_UNALIGNED_ACCESS_SUPPORT
> > +	skb =3D original skb
> > +#else
> > +	skb =3D copy skb
> > +#endif
> > +
>=20
> Couldn't this just be made an inline in a networking header somewhere,
> instead of ifdefs in the code?

That was just an example, you might want to do other things too. If it
turns out that a similar code pattern will be used all over the place we
can then consolidate that.

johannes

--=-F6/Ia8Jp6T+uxIw2Ii5u
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Comment: Johannes Berg (powerbook)

iQIVAwUAR+K3AaVg1VMiehFYAQJ10BAAlBko/4ZkLj6LW9/NGelh1GaS7iqtvvFt
M2y3cZtYTTYmAMbENKxK7WzAsOaqmv+CJyPMIulGhNwZDSeyYWEbI/g5oVjwECNo
qcd30R82k15WMBaqE56tHo4zmQ1dviQKse6UYLtyoOUDDCUTXF2pmyIwsWM+VHL0
6fuxMohW97BvP6AKxABhw7AKXykqI4/DMGcFNE3TWkHLtEivLc5MNfDx5TQAyHQO
elUpuf+B8V3W93TYwKOeTqkq+C+Xr624O9470bPytLOY6HtEpH6nLhcOeXoqJaX3
QP2MonJjMXOdmcDJEPMG4LdcExph2ZWn+rjHbCV2amABSHxLf3icxxFsTEX91FOk
rYacV/UHCF2PvSbAECW7vXMEFHnBsKpXUXTN4h6rcBWcbyaQv581z8nHiBTuCbNG
/r0fma8prIBLYo5XBmm9Lva4Q1lwPvVKaVsa97Y4I5jwWuI0sRKBqWCqx9clzs4I
vDK2d2i8zoQobBFarprybNvrxC3dvGNaVM5PT9jJfLZ4YRSYLAtQNL7cp/g/mooS
q1mUtnn5bNIrQRG5Alqeg0nBHhCZl+vCADBbHwmsi20jYxVUlBDjDIBWMluz4UtM
MJKLMQw5ziR9B9ivZ5+iN0GAJ2ffHiA2zdv1FGVDzxQhisSc2rrdBz87wYCD4Cga
KOQP31TaAxU=
=VGR/
-----END PGP SIGNATURE-----

--=-F6/Ia8Jp6T+uxIw2Ii5u--

