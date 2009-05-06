From: ext martin f krafft <madduck@madduck.net>
Subject: Re: pseudo interface with different hwaddr
Date: Wed, 6 May 2009 16:03:08 +0200
Message-ID: <20090506140308.GA16312@piper.oerlikon.madduck.net>
References: <20090210112508.GA16497@piper.oerlikon.madduck.net> <200902101343.49743.remi.denis-courmont@nokia.com> <20090210125110.GA16955@piper.oerlikon.madduck.net>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-ripemd160;
	protocol="application/pgp-signature"; boundary="Dxnq1zWXvFF0Q93v"
To: netdev discussion list <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from clegg.madduck.net ([193.242.105.96]:48853 "EHLO
	clegg.madduck.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754318AbZEFODX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 May 2009 10:03:23 -0400
Received: from piper.oerlikon.madduck.net (piper.oerlikon.madduck.net [IPv6:2001:41e0:ff12:0:211:2fff:fe6b:c869])
	(using TLSv1 with cipher DHE-RSA-AES256-SHA (256/256 bits))
	(Client CN "piper.oerlikon.madduck.net", Issuer "CAcert Class 3 Root" (verified OK))
	by clegg.madduck.net (postfix) with ESMTPS id B2C8B1D409B
	for <netdev@vger.kernel.org>; Wed,  6 May 2009 16:03:09 +0200 (CEST)
Content-Disposition: inline
In-Reply-To: <20090210125110.GA16955@piper.oerlikon.madduck.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--Dxnq1zWXvFF0Q93v
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

also sprach ext martin f krafft <madduck@madduck.net> [2009.02.10.1351 +010=
0]:
> > Wouldn't macvlan solve this?
>=20
> Thanks for the pointer. I will have to compile a kernel to test this
> though, Debian has it disabled (#504611)... :(

Works like a charm with Debian kernels >2.6.28:

piper:~# ip link add link lan address 02:34:22:ef:a2:c3 pseudo type macvlan

piper:~# ip link show pseudo
117: pseudo@lan: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc noqueue s=
tate UNKNOWN=20
    link/ether 00:34:22:ef:a2:c3 brd ff:ff:ff:ff:ff:ff

piper:~# dhclient pseudo
Internet Systems Consortium DHCP Client V3.1.2
Copyright 2004-2008 Internet Systems Consortium.
All rights reserved.
For info, please visit http://www.isc.org/sw/dhcp/

Listening on LPF/pseudo/00:34:22:ef:a2:c3
Sending on   LPF/pseudo/00:34:22:ef:a2:c3
Sending on   Socket/fallback
DHCPDISCOVER on pseudo to 255.255.255.255 port 67 interval 7
DHCPOFFER from 192.168.14.1
DHCPREQUEST on pseudo to 255.255.255.255 port 67
DHCPACK from 192.168.14.1
bound to 192.168.14.128 -- renewal in 852 seconds.



Thanks!

--=20
martin | http://madduck.net/ | http://two.sentenc.es/
=20
"next the statesmen will invent cheap lies, putting the blame upon the
 nation that is attacked, and every man will be glad of those
 conscience-soothing falsities, and will diligently study them, and
 refuse to examine any refutations of them; and thus he will by and by
 convince himself that the war is just, and will thank god for the
 better sleep he enjoys after this process of grotesque
 self-deception."
                                                         -- mark twain
=20
spamtraps: madduck.bogus@madduck.net

--Dxnq1zWXvFF0Q93v
Content-Type: application/pgp-signature; name="digital_signature_gpg.asc"
Content-Description: Digital signature (see http://martin-krafft.net/gpg/)
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.9 (GNU/Linux)

iEYEAREDAAYFAkoBmJsACgkQIgvIgzMMSnWE5ACeMjQ7OT7jWlAM/BfNsbWkFvdt
P3AAn3adsMaZLwrt1lL4WRCkdTt5FaY6
=33OH
-----END PGP SIGNATURE-----

--Dxnq1zWXvFF0Q93v--
