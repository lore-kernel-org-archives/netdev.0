From: Ben Hutchings <ben@decadent.org.uk>
Subject: Re: [RFC PATCH v2] ethtool: add IPv6 to the NFC API
Date: Mon, 25 Jan 2016 03:34:30 +0000
Message-ID: <1453692870.3734.195.camel@decadent.org.uk>
References: <56A260D9.3020004@solarflare.com>
	 <56A26F1A.1000505@solarflare.com>
	 <CAKgT0UdTLSio=LZPOzT5aiPL=GbPHXHxD6dCaBQ470f29YKq7Q@mail.gmail.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-No9A6anFAuqbOSL5nuNc"
Cc: Netdev <netdev@vger.kernel.org>
To: Alexander Duyck <alexander.duyck@gmail.com>,
	Edward Cree <ecree@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from shadbolt.e.decadent.org.uk ([88.96.1.126]:40165 "EHLO
	shadbolt.e.decadent.org.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755006AbcAYDen (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 24 Jan 2016 22:34:43 -0500
In-Reply-To: <CAKgT0UdTLSio=LZPOzT5aiPL=GbPHXHxD6dCaBQ470f29YKq7Q@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-No9A6anFAuqbOSL5nuNc
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Fri, 2016-01-22 at 10:54 -0800, Alexander Duyck wrote:
> On Fri, Jan 22, 2016 at 10:04 AM, Edward Cree <ecree@solarflare.com> wrot=
e:
[...]
> > +/**
> > + * struct ethtool_usrip6_spec - general flow specification for IPv6
> > + * @ip6src: Source host
> > + * @ip6dst: Destination host
> > + * @l4_4_bytes: First 4 bytes of transport (layer 4) header
> > + * @tos: Type-of-service
> > + * @proto: Transport protocol number (nexthdr after any Extension Head=
ers)
> > + */
> > +struct ethtool_usrip6_spec {
> > +=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0__be32=C2=A0=C2=A0ip6src[4];
> > +=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0__be32=C2=A0=C2=A0ip6dst[4];
> > +=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0__be32=C2=A0=C2=A0l4_4_bytes=
;
> > +=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0__u8=C2=A0=C2=A0=C2=A0=C2=A0=
tos;
> > +=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0__u8=C2=A0=C2=A0=C2=A0=C2=A0=
proto;
> > +};
> > +
>=20
> It might be better to refer to this as l4_proto so that it is clear
> that this is specifying the protocol of the l4 header that the
> l4_4_bytes will be pulled from.

The comment seems to make it fairly clear.

> It still might even be useful to add a nexthdr field since it is
> possible that there may be NICs out there that don't support parsing
> the extension headers.=C2=A0=C2=A0In such a case they could block setting
> protocol and use nexthdr instead.=C2=A0=C2=A0It provides an indirect way =
of
> communicating if the NIC supports parsing extension headers or not as
> the NIC can block adding a filter on one mask being set or the other.

I don't think a NIC can do any useful flow steering for IPv6 without
being able to parse and skip over the extension headers. =C2=A0It would be
like trying to match flows by looking at IPv4 header options.

Ben.

--=20
Ben Hutchings
Klipstein's 4th Law of Prototyping and Production:
                                    A fail-safe circuit will destroy others=
.
--=-No9A6anFAuqbOSL5nuNc
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIVAwUAVqWXx+e/yOyVhhEJAQopJQ/+N7KYiU+B2xsImbL1NHfmcNmNj5HS5uxL
XDRvW8kMVmcrN4Gw+egyj/AwZ8itEoP5/nrxLajvYOiJmAV/34svP/0I2O6/PVLR
lH4GB4QqvxI8e9GErJEuShihUvnCViufYvmyw7xo/IjqBw6GXOQ98345jNRFIbBn
gS37dhc6v5uZBTtU09yjTeTx9QTq5MLDM5azEcBH76/+crGicPMAMO4PtVJ+SrBf
EikKh57difbz45hmSoyE3yYiP1PAv1b5+m2kYRZxgI/dYpiDMpm01Oy0g7VZXspR
6CG9s5ANoulfqiNa0lDaWRzJQomyOjDCFJBkuOnqzjGOgi9nAQuABwSpYuQDpeyr
4JOlkwntN8ZmDjkLYpKQQSPZOG3PA6lBMW6dUv2y1XnxEJXeQ5ly7V2qQTOviU4N
RlIEPj9PcmrCDWbj1oCqS1IJRr9gG3QM05I0t+UHSpv7wf93gm3EN105Q/NabzIx
4FTDwHcFZhWzQT6r0BEVkdEHYJsghJy8l4/Uf8iGlxXFRcXrrVSVmxxZDP5NCwYE
pg2eRtPaQsV2Z88C3yS5ZPkph4JENIuQ0MmmaRY310J2GXHGUcuyqtR4wjawROe+
PPqAJ8jepPLYuc5rKoE/t0GzJmtczzG41l2LbjZotT/d4E0u8HriCl1mt/6n8oas
suNKxRJ6oL0=
=+exk
-----END PGP SIGNATURE-----

--=-No9A6anFAuqbOSL5nuNc--
