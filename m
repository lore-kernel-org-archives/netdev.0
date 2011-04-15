From: =?UTF-8?B?TWljaGHFgiBHw7Nybnk=?= <mgorny@gentoo.org>
Subject: The bonding driver should notify userspace of MAC address change
Date: Fri, 15 Apr 2011 18:44:07 +0200
Message-ID: <20110415184407.550abd88@pomiocik.lan>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=PGP-SHA1;
 boundary="Sig_/i6Z4uzImWYa+ic9er5malN6"; protocol="application/pgp-signature"
Cc: mgorny@gentoo.org, roy@marples.name
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.gentoo.org ([140.211.166.183]:44308 "EHLO smtp.gentoo.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753126Ab1DOQoB (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 15 Apr 2011 12:44:01 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--Sig_/i6Z4uzImWYa+ic9er5malN6
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

Hello,

I'd like to file a feature request for the bonding driver. Currently,
there is no way for userspace to know whether the driver actually gets
a MAC address. This results in the fact that dhcpcd sends MAC-less DHCP
packets through bonding device if it is started before bond gets any
slaves.

I've reported that problem upstream [1], and the author suggested that
the bonding driver would have to notify the userspace about MAC address
change, suggesting using RTM_NEWLINK message.

I wanted to write a patch for that but I don't seem to see any
appropriate IFF_* flag for that particular kind of event. dhcpcd author
suggested using 'ifi->ifi_change =3D ~0U' but I'm not sure if it's
appropriate.

Could you either add such a kind of notification or give me a tip on
how to proceed with adding it? Thanks in advance.

[1] http://roy.marples.name/projects/dhcpcd/ticket/212

--=20
Best regards,
Micha=C5=82 G=C3=B3rny

--Sig_/i6Z4uzImWYa+ic9er5malN6
Content-Type: application/pgp-signature; name=signature.asc
Content-Disposition: attachment; filename=signature.asc

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.17 (GNU/Linux)

iEYEARECAAYFAk2oddoACgkQnGSe5QXeB7uutgCgpVJPQuMkNhpvFqATSybIbUQq
4gMAoOWbv4sptmuYtcRyTWJauApZbvS8
=4UUj
-----END PGP SIGNATURE-----

--Sig_/i6Z4uzImWYa+ic9er5malN6--
