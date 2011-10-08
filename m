From: Jeff Kirsher <tarbal@gmail.com>
Subject: Re: e100 + VLANs?
Date: Sat, 08 Oct 2011 11:34:40 -0700
Message-ID: <4E9097C0.2030307@gmail.com>
References: <4E90212D.8030009@msgid.tls.msk.ru> <1318091046.5276.22.camel@edumazet-laptop>
Reply-To: jeffrey.t.kirsher@intel.com
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha512;
 protocol="application/pgp-signature";
 boundary="------------enig0086C36121EB9072E10DCB87"
Cc: Michael Tokarev <mjt@tls.msk.ru>, netdev <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:28236 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753243Ab1JHSek (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 8 Oct 2011 14:34:40 -0400
In-Reply-To: <1318091046.5276.22.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is an OpenPGP/MIME signed message (RFC 2440 and 3156)
--------------enig0086C36121EB9072E10DCB87
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

On 10/08/2011 09:24 AM, Eric Dumazet wrote:
> Le samedi 08 octobre 2011 =C3=A0 14:08 +0400, Michael Tokarev a =C3=A9c=
rit :
>> > Yesterday I tried to use 802.1Q VLAN tagging with an (oldish)
>> > e100-driven network card, identified by lspci like this:
>> >=20
>> >  00:12.0 Ethernet controller: Intel Corporation 82557/8/9/0/1 Ethern=
et Pro 100 (rev 02)
>> >=20
>> > Just to discover that it does not quite work: packets of
>> > size 1497+ bytes gets lost.
>> >=20
>> > This appears to be a classical problems in this case -
>> > something forgot to allocate extra 4 bytes for the
>> > packets.
>> >=20
>> > There's at least one bugreport from 2008 (!) about this
>> > very issue: http://bugs.centos.org/view.php?id=3D2719
>> > which is still open.
>> >=20
>> > The kernel I tried this on was 2.6.32, I checked git log
>> > for drivers/net/e100.c - there was no changes up to
>> > current version which may be related to this issue.
>> >=20
>> > The question: is this a driver problem or hardware? If
>> > it's the driver, can it be fixed? And if it's hardware,
>> > can the driver notify the user somehow - like, by refusing
>> > to enable VLAN (sub)devices maybe?
>> >=20
>> > Yesterday it was actually a bit more complicated for me,
>> > since the card in question was used to connect to our
>> > ISP, and they use fixed MAC address per port, so I had
>> > to find another NIC which is a) able to work with VLAN
>> > tags properly, and b) is able to change its mac address.
>> > Lucky I had a VIA RhineIII which does both :)
>> >=20
> Since you have two cards (and probably two machines), maybe you could
> try to track if the problem is a bad transmit or a bad receive ?
>
> tcpdump on both machines, and ping -s 2000 from both sides...
>
> e100 driver seems VLAN enabled at a first glance.
Eric is correct, that e100 does support VLANs.

In addition to Eric's suggestion, can you also provide all the output of
lspci -vvv for the network card?


--------------enig0086C36121EB9072E10DCB87
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.11 (GNU/Linux)
Comment: Using GnuPG with Mozilla - http://enigmail.mozdev.org/

iQIcBAEBCgAGBQJOkJfAAAoJEOVv75VaS+3OBDwP/R7E4EDaYSxeVkiBFkGCmDw1
krPJZv+ZFzk0tXuQxte21TBjwm9SBrK3g9eeNkJDHISB7HCm6cNaoOqxsulMApui
M0C0exJBW30VQq81jfxcGNGYUQLTkrKs0mj5vkKK8casRhe5lQay+gMuxuC3PnFI
IRkWsyMlCAvcDrDIFLEMKMOpVUwEkLFzMUR/FPeYFd1Gukf2nzPeMnrzC8LKKKgQ
DXp8lQmqWwvnMki7auWh+eaCgc+jdmywTApadf5iOAsQuQ11H0kjw8nALGU8iJn5
8Ivi5imer7+QuPDP7qCjKfT2JwzJx3LYL62/3sLIexzN2p+ow+/tltENvBhwEST2
w2c1DzBiVj2dY5eLPcTPI/2OJBR8eW6wC/aDrZ6Knevt0XC/UnNyUFAHwDImS48C
Q6Q6GQiTTQUVhA3bh3yLH6YlRbQP9+jPnS8y9D8Zoats9UwK6i/PK/NrlRJcKVBt
BYWOJVIfFQWC2lRP+TL8i09klJ58YUtTuzgMvCSsq9uZ8iIVHV4k6xfBmK975Ocg
IqZmL9+wDEJk74gZXujwTRWpx3LV6DQyt064cG9gKCaKo+bMixkZA29oLciczY7a
QA0iiAqFtzrD1u1XZASNBBgg+vff0gYV5k5n/uIYElIxDlJKsgCC6JfNBgX+0P2d
OuhcIpYlnQ9DNvUVADeL
=qo1B
-----END PGP SIGNATURE-----

--------------enig0086C36121EB9072E10DCB87--
