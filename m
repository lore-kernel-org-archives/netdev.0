From: Ben Hutchings <ben@decadent.org.uk>
Subject: Re: Newbie: trying to hack an RTL8101E driver
Date: Sun, 23 Feb 2014 23:29:36 +0000
Message-ID: <1393198176.6823.70.camel@deadeye.wl.decadent.org.uk>
References: <CAPNrq4wV=r6mM0i1=NZ+H-Y0ahF2Cr3xQNPRcLfuNyObp4aZqA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-TdUjapV1GPU7pElgznTg"
Cc: netdev@vger.kernel.org,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: Gideon D'souza <gidisrael@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from shadbolt.e.decadent.org.uk ([88.96.1.126]:32948 "EHLO
	shadbolt.e.decadent.org.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752168AbaBWX3q (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 23 Feb 2014 18:29:46 -0500
In-Reply-To: <CAPNrq4wV=r6mM0i1=NZ+H-Y0ahF2Cr3xQNPRcLfuNyObp4aZqA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-TdUjapV1GPU7pElgznTg
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Mon, 2014-02-24 at 02:39 +0530, Gideon D'souza wrote:
> So I've submitted some patches for some tiny ongoing refactoring.
>=20
> In the hopes of moving to more _real_ work I've been snooping at the
> ethernet drivers. I was especially curious about driver code that is
> running  for my own hardware.
>=20
> I found out with lshw that I'm running a Atheros QCA9565 / AR9565
> Wireless Network Adapter and a  RTL8101E/RTL8102E NIC.

> For the atheros drivers after much google-fun I came by this
> wireless.kernel.org/en/users/Drivers/ath9k and (correct me if I'm
> wrong) there isn't a datasheet for this (and generally atheros)
> drivers? They've been rev-engg'd ?

The ath9k driver is supported by Qualcomm-Atheros - no
reverse-engineering required.  I don't know what their policy is for
releasing programming manuals, but it might require an NDA.

> I went on the the realtek driver, I found this article on writing a
> realtek driver (http://linuxgazette.net/156/jangir.html) I also looked
> at Linux Device Drivers, both are pretty old. I also started reading
> Documentation/pci/*
[...]

The Realtek chips (RTL8101E and RTL8102E) are meant to be supported by
r8169 so there is no need for a new driver.

Ben.

--=20
Ben Hutchings
All the simple programs have been written, and all the good names taken.

--=-TdUjapV1GPU7pElgznTg
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIVAwUAUwqEYOe/yOyVhhEJAQptgw/+MBH2KSIaFAcckv61AuNHKLucvGhCgzPC
aHKbDVyTsW3yGbcTslkDau9G5GtpN91UqsuuE7iIf8KZN3Dpk7lC/IySLAdrDcAS
4nbscvmuTg3g4ny+jlmsB8jFE6NIKHZ0hoTX8Rk2/ZzVipZ7r2N90PYUNg93EV4B
WOWHuviygt8MPSU2YI8khmTldREaIZ/zg946czwwWBRTXxxL/mZqtG8M1+duOdNt
RG0EfEARYkWv2A7SjYIXiRYH7WAjFR6cTc0nc6Fak8Yj5Fi/KaKGdaxn8IYT3gl7
oOteQPc+OyhKw2vq73/pF95Udt/9dZleFZcDBij8g8ixdUiXJ+5zohNlSnoNp3Lc
rkspLRWTaVCp+4J0l6RuV+Fs5xnxyndz8MbGWvXJ0zXf7rnFuwG+MJNopZfi/Ao2
udVPwfT859ph9MTtVAjLgesjXfw9CpX/WjUgyv68r6mid0KD32Axj6BXSAjpCJBp
DgyrpJeZ6MXAzIKlmHWizp0JVEbVFvRmandfge3xzKGm5CSwTA3bOp1Go6lZ2Q88
cSTpBBxeaSW19cPj0rpkldBJb6NggeHRsNz/hRO2O4fhFJ8y/tYgnKyP7KqDRAux
E1gFMrOnzysoapbxMWlHt3MYg6WtLQ82DLLMiqWOOA+SAA7Sr+klgA27+5K8JF11
0IVVmwVhJHM=
=5CLd
-----END PGP SIGNATURE-----

--=-TdUjapV1GPU7pElgznTg--
