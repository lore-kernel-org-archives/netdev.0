From: Sergiy Kibrik <sakib@meta.ua>
Subject: Re: [PATCH] usb:smsc: preserve MAC address when resetting device
Date: Tue, 1 Feb 2011 22:58:42 +0200
Message-ID: <201102012258.49375.sakib@meta.ua>
References: <1296556457-4969-1-git-send-email-sakib@meta.ua> <20110201112425.GA3407894@jupiter.n2.diac24.net>
Reply-To: sakib@meta.ua
Mime-Version: 1.0
Content-Type: multipart/signed;
  boundary="nextPart1476530.OujcjSqB84";
  protocol="application/pgp-signature";
  micalg=pgp-sha1
Content-Transfer-Encoding: 7bit
Cc: Steve Glendinning <steve.glendinning@smsc.com>,
	netdev@vger.kernel.org, linux-usb@vger.kernel.org
To: David Lamparter <equinox@diac24.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.meta.ua ([194.0.131.41]:48983 "EHLO smtp.meta.ua"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752496Ab1BAU7D (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 1 Feb 2011 15:59:03 -0500
In-Reply-To: <20110201112425.GA3407894@jupiter.n2.diac24.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--nextPart1476530.OujcjSqB84
Content-Type: Text/Plain;
  charset="us-ascii"
Content-Transfer-Encoding: quoted-printable

On Tuesday 01 February 2011 13:24:25 David Lamparter wrote:
> You cannot do that. Imagine if I plug in two devices. Only the first one
> will get a MAC properly. Or imagine if i plug a device, unplug it and
> plug it back. It will have an uninitialized mac address.
>=20
> You need to move the init_mac_address call to happen on device plug-in.
>=20
>=20
> -David

Sorry, didn't take into account such case. Will resubmit

=2Dregards,
Sergey

--nextPart1476530.OujcjSqB84
Content-Type: application/pgp-signature; name=signature.asc 
Content-Description: This is a digitally signed message part.

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.14 (GNU/Linux)

iJwEAAECAAYFAk1IdAkACgkQDcLhAeYaZvhPdAP8DII4D0Guqv6nCiTIlg2MLBal
x5hBkBW1m4TweqFd+NUh8APxY2IvADJm4r5NeY77pn5Zujbjo5GFKW/yeGAultL+
VDzzn3WUDkVWfkZrC3LlJjIGDiPr1VR011fOogdyZZQ6smihgNc+C6uPgEBziFEZ
JrXWlGEiLGL8nPvqtiI=
=MtBO
-----END PGP SIGNATURE-----

--nextPart1476530.OujcjSqB84--
