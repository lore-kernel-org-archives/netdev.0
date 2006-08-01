From: Sven Schuster <schuster.sven@gmx.de>
Subject: Re: [patch] RFC: matching interface groups
Date: Tue, 1 Aug 2006 21:18:05 +0200
Message-ID: <20060801191805.GA28649@zion.homelinux.com>
References: <1154452209.6395.77.camel@bzorp.balabit> <20060801184655.GA7452@linuxace.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="3V7upXqbjpZ4EhLz"
Cc: netfilter-devel@lists.netfilter.org,
	Balazs Scheidler <bazsi@balabit.hu>, netdev@vger.kernel.org,
	shemminger@osdl.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.gmx.de ([213.165.64.21]:64204 "HELO mail.gmx.net")
	by vger.kernel.org with SMTP id S1751827AbWHATST (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Aug 2006 15:18:19 -0400
To: Phil Oester <kernel@linuxace.com>
Content-Disposition: inline
In-Reply-To: <20060801184655.GA7452@linuxace.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--3V7upXqbjpZ4EhLz
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable


Hi Phil,

On Tue, Aug 01, 2006 at 11:46:55AM -0700, Phil Oester told us:
> Since in this scenario userspace is able to determine ppp vs pptp,=20
> could you not also do something like have an inbound_ppp and inbound_pptp
> chain, then jump to the appropriate chain depending on type?  If you
> need per-interface rules, then create an inbound_pppX chain, populate
> it with rules, then jump to that chain if -i pppX.  In ip-down, just
> delete the chain as well as the jump.

if I understood Balazs correctly, one of the things he wanted to
avoid is addition/deletion of iptables rules on every pppX interface
up/down as this would require the complete chain (say, INPUT or
OUTPUT) to be "downloaded" to userspace, modified and then again
"uploaded" to the kernel. At least until iptables redesign to
allow replacement/insertion/deletion of single rules is completed
which if started at all will take quite some more time :-)


Sven

> Phil
>=20

--=20
Linux zion.homelinux.com 2.6.17-rc5-mm1_35 #35 Tue May 30 14:11:06 CEST 200=
6 i686 athlon i386 GNU/Linux
 21:13:05 up 19:46,  2 users,  load average: 0.22, 0.28, 0.27

--3V7upXqbjpZ4EhLz
Content-Type: application/pgp-signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.4 (GNU/Linux)

iD8DBQFEz6jto4FAdB2PneQRAkAzAJ0YKQnbMs/c8DksDFylkglkeBSM0gCeK/D2
vaY8vmtcIWAWK1yPqoyR+iM=
=fyeY
-----END PGP SIGNATURE-----

--3V7upXqbjpZ4EhLz--
