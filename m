From: Jeroen Massar <jeroen@unfix.org>
Subject: Re: [RFC] ip / ifconfig redesign
Date: Mon, 05 Dec 2005 15:20:36 +0100
Message-ID: <43944CB4.60709@unfix.org>
References: <200512022253.19029.a1426z@gawab.com> <200512031646.45332.a1426z@gawab.com> <4391E4FC.1040200@candelatech.com> <20051205140057.GC24764@tuxdriver.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="------------enig2D54E97E726A371E3193CB76"
Return-path: <linux-net-owner@vger.kernel.org>
To: Ben Greear <greearb@candelatech.com>, Al Boldi <a1426z@gawab.com>,
	netdev@vger.kernel.org, linux-net@vger.kernel.org
In-Reply-To: <20051205140057.GC24764@tuxdriver.com>
Sender: linux-net-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 2440 and 3156)
--------------enig2D54E97E726A371E3193CB76
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

John W. Linville wrote:

<SNIP>
> Of course, patches would be helpful...

/sbin/ipadd <address>
#!/bin/sh
ip addr add $1 dev lo

/sbin/ipdel <address>
#!/bin/sh
ip addr del $1 dev lo

/sbin/ipactivate <address> <device>
#!/bin/sh
ip addr add $1 dev $2

/sbin/ipdeactivate <address> <device>
#!/bin/sh
ip addr del $1 dev $2

There are your 'patches'. Add -6's to places for IPv6 versions.

Greets,
 Jeroen



--------------enig2D54E97E726A371E3193CB76
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.2 (MingW32)
Comment: Jeroen Massar / http://unfix.org/~jeroen/

iD8DBQFDlEy0KaooUjM+fCMRAtL6AJ9okrvLX4U6+iG1phowB9etb12C7ACfflYe
QfNHwJZMWY9TgR6EgvIK3PE=
=G3vT
-----END PGP SIGNATURE-----

--------------enig2D54E97E726A371E3193CB76--
