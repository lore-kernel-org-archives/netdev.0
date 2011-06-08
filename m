From: Ben Hutchings <ben@decadent.org.uk>
Subject: Re: Bug#629604: linux-image-2.6.38-2-686: sky2 eth0 rx length
 errors (~5/second)
Date: Wed, 08 Jun 2011 04:26:15 +0100
Message-ID: <1307503575.22348.495.camel@localhost>
References: <20110608015806.3543.25300.reportbug@nomad>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512"; protocol="application/pgp-signature"; boundary="=-3AzqxKQrPqqzvE6bu4fA"
Cc: 629604@bugs.debian.org,
	Stephen Hemminger <shemminger@linux-foundation.org>,
	netdev <netdev@vger.kernel.org>
To: Kate Gordon <freedomtea@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from shadbolt.e.decadent.org.uk ([88.96.1.126]:46586 "EHLO
	shadbolt.e.decadent.org.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751688Ab1FHD0g (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 Jun 2011 23:26:36 -0400
In-Reply-To: <20110608015806.3543.25300.reportbug@nomad>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-3AzqxKQrPqqzvE6bu4fA
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Wed, 2011-06-08 at 11:58 +1000, Kate Gordon wrote:
> Package: linux-2.6
> Version: 2.6.38-5
> Severity: normal
>=20
> On my first ethernet connection after an upgrade from squeeze (2.6.35)

The current kernel package version in squeeze is 2.6.32-34squeeze1, but
that does have the sky2 driver from Linux 2.6.35.

> to wheezy (2.6.38), I started=20
> seeing the sky2 errors shown below in the kernel log.  So far my
> internet is still working (I detect
> a slight slowness but that's it).  Looks to be the same as Ubuntu bug=20
> https://bugs.launchpad.net/ubuntu/+source/linux/+bug/719873
>=20
> Ethernet controller:
> $lscpi
> <snip>
> Ethernet controller: Marvell Technology Group Ltd. 88E8053 PCI-E Gigabit =
Ethernet Controller (rev 22)
> </snip>
>=20
> I'm on a MacBook Pro 1,1.
> Please let me know if there's any other pertinent info I can give

The driver should log a message of the form
'Yukon-2 <name> chip revision <number>' at startup.  I think we may need
to know the name and number.

> -- Package-specific info:
> ** Version:
> Linux version 2.6.38-2-686 (Debian 2.6.38-5) (ben@decadent.org.uk) (gcc v=
ersion 4.4.6 (Debian 4.4.6-3) ) #1 SMP Sun May 8 14:49:45 UTC 2011
>=20
> ** Command line:
> BOOT_IMAGE=3D/boot/vmlinuz-2.6.38-2-686 root=3DUUID=3D7e5efdb0-6919-4e56-=
a96b-45055f82dcf0 ro
>=20
> ** Not tainted
>=20
> ** Kernel log:
> [ 3118.574281] sky2 0000:02:00.0: eth0: rx error, status 0x5c2300 length =
92
> [ 3121.260783] net_ratelimit: 11 callbacks suppressed
> [ 3121.260795] sky2 0000:02:00.0: eth0: rx error, status 0x5c2300 length =
92
> [ 3121.366680] sky2 0000:02:00.0: eth0: rx error, status 0x972300 length =
151
> [ 3121.763382] sky2 0000:02:00.0: eth0: rx error, status 0x5c2300 length =
92
> [ 3122.014215] sky2 0000:02:00.0: eth0: rx error, status 0xd92300 length =
217
[...]

This status value indicates a VLAN-tagged packet, so this is probably
related to changes in VLAN support.

Ben.

--=20
Ben Hutchings
Once a job is fouled up, anything done to improve it makes it worse.

--=-3AzqxKQrPqqzvE6bu4fA
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.11 (GNU/Linux)

iQIVAwUATe7r1+e/yOyVhhEJAQobBRAAqClbX20HW294SFX1r1W917SNXr80qngE
aelqI/kCiKHqhTmg01GsuK+vMHwVypjcUSkeH9um+jCrhRJdUqxnncC1MRhVtUV1
Hq0FnuYlua1II+xgcSfc+xQShpdzFs47R+RBamq/YLu7cTRzuF21Lvw2n8O6+MaR
AZWbl0H/HjDb0o/T3FLPBBiL0fo7kUSJ1uYA9spvYJwuTON6BqiV6E5kV7j9rvGk
13xUumcCk+7UChmAHaiQ6QSIhB3hL7hlz54+9iX4MDHR7dy2cI+Qv+1NBNOcKxmw
IFHmqlyeXws4ZKIoJa22O5YnHh4gDmWVEZUUlLFvflpKcKv6Ek5E/EBJvmvA5Ilm
5K1o0BXN2KYWcLP7/zYb3dNsALCgi8yDUeDDQptSDXdUbl+L0IIgompBESRHlDCy
MjMPo+BzthwrIf7waAuiYc/dIkZbACIBUmN+q0xb7vZeUFWhkGNqgPmwoJ8/0ANZ
+59LaBin3TiTlMCMuYQl5u/ZfcZwb+n0H7pSt/CawdOXQO51T3V1hnVU0X+JEdV0
7LneojC3cyjgQktQ8iLeX9ppLIdch7wy9S99NU8zRkKRyRXd+4NMTdRL5MuZtvvE
thDM91JE04Sc3RGfzTaPSDBKK2S6wlmE3WA96djrTRe8IpKzUggVDjpcQhunOAHN
pUJ4l0m6r2Q=
=FvYz
-----END PGP SIGNATURE-----

--=-3AzqxKQrPqqzvE6bu4fA--
