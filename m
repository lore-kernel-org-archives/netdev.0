From: Michael Wu <flamingice@sourmilk.net>
Subject: Re: [PATCH 04/26] rt2x00: EEPROM 93Cx6
Date: Sun, 3 Dec 2006 13:39:24 -0500
Message-ID: <200612031339.28148.flamingice@sourmilk.net>
References: <200612031919.05228.IvDoorn@gmail.com>
Mime-Version: 1.0
Content-Type: multipart/signed;
  boundary="nextPart1604093.nt9F1b16f6";
  protocol="application/pgp-signature";
  micalg=pgp-sha1
Content-Transfer-Encoding: 7bit
Cc: "John W. Linville" <linville@tuxdriver.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from server8.tchmachines.com ([216.180.241.250]:44200 "EHLO
	server8.tchmachines.com") by vger.kernel.org with ESMTP
	id S1759977AbWLCSkc (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 3 Dec 2006 13:40:32 -0500
To: Ivo van Doorn <ivdoorn@gmail.com>
In-Reply-To: <200612031919.05228.IvDoorn@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--nextPart1604093.nt9F1b16f6
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Content-Disposition: inline

On Sunday 03 December 2006 13:19, Ivo van Doorn wrote:
> rt2400pci, rt2500pci and rt61pci share exactly the
> same code for the eeprom reading. The only difference
> is that rt61pci has a slightly different register reading
> approach. In any case we have a lot of duplicate code.
> Create a new module eeprom_93cx6 inside the rt2x00 folder
> and make rt2x00 use that.
Interesting. adm8211 has code to read 93C66 and 93C46 eeproms, and it looks=
=20
similar, albeit smaller and simpler, to your 93cx6 reading code. However, i=
t=20
looks like your new eeprom reading code is general enough for adm8211 to us=
e=20
too. I'll have to try it..

=2DMichael Wu

--nextPart1604093.nt9F1b16f6
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.2 (GNU/Linux)

iD8DBQBFcxngT3Oqt9AH4aERAmQUAKChBb3xVp2UbyDbAiSx2ukPyAmHhgCcDc34
xkZBKXkEWJxDL4WQALqxTHE=
=C9Az
-----END PGP SIGNATURE-----

--nextPart1604093.nt9F1b16f6--
