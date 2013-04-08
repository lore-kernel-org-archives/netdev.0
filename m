From: Antonio Quartulli <ordex@autistici.org>
Subject: Re: Ignoring destination MAC address in incoming packets
Date: Mon, 8 Apr 2013 09:19:03 +0200
Message-ID: <20130408071903.GB5938@ritirata.org>
References: <m3txnhmrdm.fsf@intrepid.localdomain>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
	protocol="application/pgp-signature"; boundary="i7F3eY7HS/tUJxUd"
Cc: netdev@vger.kernel.org
To: Krzysztof Halasa <khc@pm.waw.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from diserzione.investici.org ([82.221.99.153]:57795 "EHLO
	diserzione.investici.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S934371Ab3DHHU1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Apr 2013 03:20:27 -0400
Content-Disposition: inline
In-Reply-To: <m3txnhmrdm.fsf@intrepid.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--i7F3eY7HS/tUJxUd
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Mon, Apr 08, 2013 at 09:08:21AM +0200, Krzysztof Halasa wrote:
> Hi,
>=20
> I have a bit unusual problem today. Is there a way to ignore destination
> MAC address in incoming packets?
>=20
> I need to do this on Atheros Wi-Fi. Basically what I need to achieve is
> a sniffer.
>=20
> Something like this:
> - ATH5k working in ad-hoc mode, certain ESSID and channel selected.
> - UDP packets in certain range are to be forwarded to other IPs.
> - the wifi interface must be able to normally communicate (within its
>   ESSID and channel).
> - it has to work with iptables etc. (DNAT, routing).
>=20
> I know I can change a line in the kernel (the one setting pkt_type to
> OTHER_HOST) but perhaps there is some standard way for things like this?
>=20
> Or should I use AF_PACKET and forward the data with userspace helper?
>=20
> Any other idea?

May be a stupid suggestion, but what about setting promisc mode on?

Cheers,

--=20
Antonio Quartulli

=2E.each of us alone is worth nothing..
Ernesto "Che" Guevara

--i7F3eY7HS/tUJxUd
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.19 (GNU/Linux)

iQIcBAEBCAAGBQJRYm9nAAoJEADl0hg6qKeO2lgQAKR/Lzl4xqteDWSlM4cxpXMQ
k4drCDExJ6S79e9siKjTUPd7h4IoovMxN1dKTRW2fePf2IUgwnmIWMVbWPXZStyf
13D8++Zd/vXncZxaoGa8A3hi933SvUcUSiototP2rDOe4C6jU7Dz/Xz8KzUzF/T2
ubWSTEw+XCgC9Mz0ZFBR02Qv6eW+dkAXPtJ/voysNcZumxKa260zKyMkYIu4Rs7t
An38YZT9kGLyDytZSaow6eEBcnu4Pinh0rYsyVKc7ca7Ga8ZLudTIxWmGntaN0fv
2eVoNe45Wqx1V40GHU8tBDGQ/REjwPjpED7i5MMjDRie/AlvF53GaYKZbtJSAQAS
ajS+bVqVJwGVHuDGl/48uHxz8gwzCNcJc8USYoePAm2ajycsB38P+9OgTZprzSd2
Bm6Ia1Ch4MhUWGFLzBE01LVgBeiBlSpyuGsVLGpB9Lj3qdZqH3xgSeOO8tEbqeeC
71R6JKuhnECyOe9NvzFRpKSomx4qtqkaqbNAqaDKBJeSvrruGS3eXlkJetIO6ffU
uZrpzXQlnqDX+AkCS4oKE68EySgufP08UZnJqqcvEVV+5mrHhrSTZXHfEVQdvEZk
gNZBMN9+BFmmF52UPd1YOrEwQDanl8qMDr0qbt2xw0msXa0SnUiO3XHNM2zNl3Fi
AcRC82ESeKfrc68Vttzf
=iocU
-----END PGP SIGNATURE-----

--i7F3eY7HS/tUJxUd--
