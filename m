From: Ben Hutchings <ben@decadent.org.uk>
Subject: Re: ax88796 driver
Date: Tue, 22 Apr 2014 02:59:59 +0100
Message-ID: <1398131999.3624.167.camel@deadeye.wl.decadent.org.uk>
References: <534F1550.50704@mail.ru>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-8+B/ADpDq+7q1ubqJCnB"
Cc: netdev@vger.kernel.org, Ben Dooks <ben.dooks@codethink.co.uk>
To: Alexander Varnin <fenixk19@mail.ru>
Return-path: <netdev-owner@vger.kernel.org>
Received: from shadbolt.e.decadent.org.uk ([88.96.1.126]:51713 "EHLO
	shadbolt.e.decadent.org.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752536AbaDVCAQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Apr 2014 22:00:16 -0400
In-Reply-To: <534F1550.50704@mail.ru>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-8+B/ADpDq+7q1ubqJCnB
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Thu, 2014-04-17 at 03:42 +0400, Alexander Varnin wrote:
> Hello!
>=20
> I am currently working on kernel and dealing with ax88796 driver, that
> has been written by Ben Dooks <ben@simtec.co.uk>. Since his address is
> not available anymore (says "Ben doesn't work here any more"), I want
> to ask help from somebody, who maybe somehow related to this driver.

I'm cc'ing Ben, but I doubt he'll want to remember this driver.

Ben.

> I want to ask on source code, because there is some non-obvious lines.
>=20
> Take a look on ax_initial_check function from ax88796.c please [1].
>=20
> Here is lines 127-129 of it:
>=20
> ei_outb (E8390_NODMA + E8390_PAGE1 + E8390_STOP, ioaddr + E8390_CMD);
> regd =3D ei_inb (ioaddr + 0x0d);
> ei_outb (0xff, ioaddr + 0x0d);
>=20
> This is supposed to be read and write to 0xD register on PAGE 1 of
> AX88796. But that offset stands for "Multicast Address Register 5
> ( MAR5 )" in AX88796 datasheet [2].
>=20
> What is the point of doing so? That looks very like a mistake. If it
> is a mistake, I could make and send patch to fix it. But, please,
> explain why is it done?
>=20
>=20
> [1] http://lxr.free-electrons.com/source/drivers/net/ethernet/8390/ax8879=
6.c#L116
> [2] http://www.digchip.com/datasheets/parts/datasheet/562/AX88796-pdf.php


--=20
Ben Hutchings
Beware of programmers who carry screwdrivers. - Leonard Brandwein

--=-8+B/ADpDq+7q1ubqJCnB
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIVAwUAU1XNH+e/yOyVhhEJAQqJ+Q//VlEY00dJ4+XXUSqHme3KTcDN7Zu/YkA4
CQ7WoBv/M626ryFnXk6TgEkH4VO9oSaJl0bLfRAd+xqwSP/GEKW7/bMFAYtjKglt
cw4ZzRu6Yga8G6uf4YqszAT17XfHV58GvXeLSbU6mIq8fi87+DKSUETXQtFMap3q
HimxXSIRPoRgWsC7SJ/ZOuQetubChX2vgUtKywz3KxugvarQVMhUVdSk8Bvq0TQ/
922Wm3bqZKUUww7LlBjDlEW5h9oqMSJAqI+Wc2RPTP4ethSU5eaOCBfi1b0pT+MU
JL7aujAMeE2+3GbrU86SCPVnZKZkq3tHuKzcKbH2YZJq+KJ53mYlutLCXyuwNlMk
+vaRKMAWoFkdnmA9oasBXmMbVPV4cLBGRFFfePmTV4Wiwbz8YWR5ixMoziuW607M
LH0mT6i8fCZsDsiO2SkI7f1rovk7bkapmjjDEEZieanSfSvKaX03D/pvgrPdLDuW
pBS7TnTqrQlXsQULYK/jOqoYB2ALwoWQe8IQlkMgChHXrzT67lqPfZXFeaAMvotG
s0lKFyrNpOLZ0Q0byoknCClJMqbbjlKY3QHdSBbGeHXOmC18S+TZnCmtEDrSPi10
LT3oLHKbFH/U5m/DVP6M6VqDIRjAHVeKJqV2iYvwmAdcJR2xUdxtOelqUD8HyfHn
wehC8XiNMMA=
=+MHl
-----END PGP SIGNATURE-----

--=-8+B/ADpDq+7q1ubqJCnB--
