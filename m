From: Nikola Ciprich <nikola.ciprich@linuxbox.cz>
Subject: Re: bnx2x - occasional high packet loss (on LAN)
Date: Mon, 21 Sep 2015 12:58:40 +0200
Message-ID: <20150921105840.GJ9248@pcnci.linuxbox.cz>
References: <20150915041726.GD6850@pcnci.linuxbox.cz>
 <81D78EA7F834FA4C83B64260D494C8590870F221@avmb3.qlogic.org>
 <20150916081833.GE6850@pcnci.linuxbox.cz>
 <20150921103200.GF6850@pcnci.linuxbox.cz>
 <81D78EA7F834FA4C83B64260D494C859087192AE@avmb3.qlogic.org>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="ZxoMK3jQATP4mxSH"
Cc: netdev <netdev@vger.kernel.org>,
	"nik@linuxbox.cz" <nik@linuxbox.cz>
To: Ariel Elior <Ariel.Elior@qlogic.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gwu.lbox.cz ([62.245.111.132]:40206 "EHLO gwu.lbox.cz"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932164AbbIUK6r (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 21 Sep 2015 06:58:47 -0400
Content-Disposition: inline
In-Reply-To: <81D78EA7F834FA4C83B64260D494C859087192AE@avmb3.qlogic.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--ZxoMK3jQATP4mxSH
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

> Hi Nikola,
> Seems like the link below is the same file you shared before - I don't se=
e any errors there.

ouch, the file was correct, but the permissions were wrong..
so maybe you were getting older file from some proxy?

anyways, I've copied file so you can get it from
new location:

http://nik.lbox.cz/download/dmesg2.txt



>=20
> Two things you can collect for me to help debug this issue:
>=20
> 1.
> Output of ethtool -d eth1 after problem occurs (redirect to a file)

here it is:
http://nik.lbox.cz/download/ethtool-eth4.txt
http://nik.lbox.cz/download/ethtool-eth5.txt

> 2.
> dmesg after enabling link related debug messages. Use
> modprobe bnx2x debug=3D0x4
> Or
> ethtool -s eth1 msglvl 0x4

I have set this for both interfaces, but don't see anything new
in dmesg..


> to enable these prints.
>=20
> This holds for both of your problems (unless it is the same issue).
>=20
> Thanks,
> Ariel
>=20

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

--ZxoMK3jQATP4mxSH
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.14 (GNU/Linux)

iEYEARECAAYFAlX/4uAACgkQ3xdJJrLygV5MQACfUQzGwg+bJ6yw97jyv1IGIdaK
OsYAn0fceGJiPo3jWZdQj1sBWo4uonYf
=8wjV
-----END PGP SIGNATURE-----

--ZxoMK3jQATP4mxSH--
