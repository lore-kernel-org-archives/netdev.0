From: Nikola Ciprich <nikola.ciprich@linuxbox.cz>
Subject: Supermicro AOC-STGN-i2S w intel 82599ES on Brocade ICX6610 - random
 link failures
Date: Mon, 25 Jan 2016 11:08:51 +0100
Message-ID: <20160125100851.GA7545@nbnik.linuxbox.cz>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="2fHTh5uZTiUOsy+g"
Cc: nik@linuxbox.cz, Stanislav Schattke <schattke@linuxbox.cz>
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gwu.lbox.cz ([62.245.111.132]:56708 "EHLO gwu.lbox.cz"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755368AbcAYKYP (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 25 Jan 2016 05:24:15 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--2fHTh5uZTiUOsy+g
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hello netdev readers,

I'd like to consult following problem we're dealing with:

I have a cluster of three nodes connected to stacked Brocade ICX6610
switches using bonded AOC-STGN-i2S adapters (they're using 82599ES
chipsets).

The problem is, I see random link failures on practically all
interfaces. Link always goes down for very short time, then adapter
is reset and link goes up again.

Here's dmesg snippet:

[Jan22 22:09] ixgbe 0000:03:00.0 eth0: NIC Link is Down
[  +0.005610] ixgbe 0000:03:00.0 eth0: initiating reset to clear Tx work af=
ter link loss
[  +0.012792] bond0: link status definitely down for interface eth0, disabl=
ing it
[  +1.105826] ixgbe 0000:03:00.0 eth0: Reset adapter
[  +0.307518] ixgbe 0000:03:00.0 eth0: detected SFP+: 3
[  +0.145881] ixgbe 0000:03:00.0 eth0: NIC Link is Up 10 Gbps, Flow Control=
: RX/TX

since I'm using bonding, it doesn't disrupt traffic, but I'd still like to
resolve it. We're using 5m passive SFP cables, we tried replacing one with =
3m
piece, to no avail.=20

all three boxes are supermicro X10DRW, running vanilla x86_64 4.0.5 kernel =
(I'll upgrade it to 4.1.16 soon)

we were using broadcom adapter before and they were working without such pr=
oblems
(except for one particular port, which showed mysterious packet drops every=
 few
months, thats why we switched to intel-based adapters), so I think cables a=
nd switches
should be fine, but I'm not sure of course

I think I've seen similar problems and they were PM related, but I'm not su=
re..

anyone seen similar problem?

or some tips on how could I debug it?

If I could provide more information, please let me know

BR

nik

--=20
-------------------------------------
Ing. Nikola CIPRICH
LinuxBox.cz, s.r.o.
28.rijna 168, 709 00 Ostrava

tel.:   +420 591 166 214
fax:    +420 596 621 273
mobil:  +420 777 093 799
www.linuxbox.cz

mobil servis: +420 737 238 656
email servis: servis@linuxbox.cz
-------------------------------------

--2fHTh5uZTiUOsy+g
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.14 (GNU/Linux)

iEYEARECAAYFAlal9DMACgkQ3xdJJrLygV41dgCggP+dXDxK704IfzaEknPn42kI
BcUAoOJJqSRIJMZ0M5hdXoJcPi40PSE2
=acxT
-----END PGP SIGNATURE-----

--2fHTh5uZTiUOsy+g--
