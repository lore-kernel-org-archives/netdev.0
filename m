From: Nikola Ciprich <nikola.ciprich@linuxbox.cz>
Subject: Re: bnx2x - occasional high packet loss (on LAN)
Date: Fri, 9 Oct 2015 09:59:21 +0200
Message-ID: <20151009075921.GG6850@pcnci.linuxbox.cz>
References: <20150915041726.GD6850@pcnci.linuxbox.cz>
 <81D78EA7F834FA4C83B64260D494C8590870F221@avmb3.qlogic.org>
 <20150916081833.GE6850@pcnci.linuxbox.cz>
 <20150921103200.GF6850@pcnci.linuxbox.cz>
 <81D78EA7F834FA4C83B64260D494C859087192AE@avmb3.qlogic.org>
 <20150921105840.GJ9248@pcnci.linuxbox.cz>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="64j1qyTOoGvYcHb1"
Cc: netdev <netdev@vger.kernel.org>,
	"nik@linuxbox.cz" <nik@linuxbox.cz>,
	Nikola Ciprich <nikola.ciprich@linuxbox.cz>
To: Ariel Elior <Ariel.Elior@qlogic.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gwu.lbox.cz ([62.245.111.132]:34232 "EHLO gwu.lbox.cz"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755805AbbJIH70 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 9 Oct 2015 03:59:26 -0400
Content-Disposition: inline
In-Reply-To: <20150921105840.GJ9248@pcnci.linuxbox.cz>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--64j1qyTOoGvYcHb1
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hello Ariel,

finally, I was able to reproduce the problem with debug set as you
requested..

> > Two things you can collect for me to help debug this issue:
> >=20
> > 1.
> > Output of ethtool -d eth1 after problem occurs (redirect to a file)
>=20
> here it is:
> http://nik.lbox.cz/download/ethtool-eth4.txt
> http://nik.lbox.cz/download/ethtool-eth5.txt
>=20
> > 2.
> > dmesg after enabling link related debug messages. Use
> > modprobe bnx2x debug=3D0x4
> > Or
> > ethtool -s eth1 msglvl 0x4

here it is:

http://nik.lbox.cz/download/dmesg3-box1.txt

http://nik.lbox.cz/download/dmesg3-box2.txt

will this help?

BR

nik


>=20
> I have set this for both interfaces, but don't see anything new
> in dmesg..
>=20
>=20
> > to enable these prints.
> >=20
> > This holds for both of your problems (unless it is the same issue).
> >=20
> > Thanks,
> > Ariel
> >=20
>=20
> --=20
> -------------------------------------
> Ing. Nikola CIPRICH
> LinuxBox.cz, s.r.o.
> 28.rijna 168, 709 00 Ostrava
>=20
> tel.:   +420 591 166 214
> fax:    +420 596 621 273
> mobil:  +420 777 093 799
> www.linuxbox.cz
>=20
> mobil servis: +420 737 238 656
> email servis: servis@linuxbox.cz
> -------------------------------------



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

--64j1qyTOoGvYcHb1
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.14 (GNU/Linux)

iEYEARECAAYFAlYXc9kACgkQ3xdJJrLygV64zQCdFCyayPol6LPoNOWdkEn7kzXe
Oj4AmwXOxVegqAcsifcNk9gZwSwnr/Zv
=j2xp
-----END PGP SIGNATURE-----

--64j1qyTOoGvYcHb1--
