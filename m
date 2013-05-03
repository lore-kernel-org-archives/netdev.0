From: Nikola Ciprich <nikola.ciprich@linuxbox.cz>
Subject: tg3 adapter losing link - PM related?
Date: Fri, 3 May 2013 11:28:46 +0200
Message-ID: <20130503092846.GA5126@pcnci.linuxbox.cz>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="k1lZvvs/B4yU6o8G"
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from gwu.lbox.cz ([62.245.111.132]:33125 "EHLO gwu.lbox.cz"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751518Ab3ECJ2s (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 3 May 2013 05:28:48 -0400
Received: from pcnci (pcnci.linuxbox.cz [10.76.3.14])
	by gwu.lbox.cz (Sendmail) with ESMTP id r439SkmZ001172
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NO)
	for <netdev@vger.kernel.org>; Fri, 3 May 2013 11:28:46 +0200
Received: from pcnci.linuxbox.cz (localhost.localdomain [127.0.0.1])
	by pcnci (8.14.5/8.14.5) with SMTP id r439SkSK010175
	for <netdev@vger.kernel.org>; Fri, 3 May 2013 11:28:46 +0200
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--k1lZvvs/B4yU6o8G
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hello,

I'd like to ask about trouble I've got with new HP server: tg3 adapter keep=
s losing
link every few minutes:

Aug  3 03:58:02 atlovav1a kernel: [616741.147598] tg3 0000:03:00.0: eth0: L=
ink is down
Aug  3 03:58:04 atlovav1a kernel: [616743.943456] tg3 0000:03:00.0: eth0: L=
ink is up at 100 Mbps, full duplex
Aug  3 03:58:04 atlovav1a kernel: [616743.943598] tg3 0000:03:00.0: eth0: F=
low control is on for TX and on for RX
Aug  3 03:58:04 atlovav1a kernel: [616743.943736] tg3 0000:03:00.0: eth0: E=
EE is enabled
Aug  3 04:14:29 atlovav1a kernel: [617727.980487] tg3 0000:03:00.0: eth0: L=
ink is down
Aug  3 04:14:32 atlovav1a kernel: [617730.847245] tg3 0000:03:00.0: eth0: L=
ink is up at 100 Mbps, full duplex
Aug  3 04:14:32 atlovav1a kernel: [617730.847387] tg3 0000:03:00.0: eth0: F=
low control is on for TX and on for RX
Aug  3 04:14:32 atlovav1a kernel: [617730.847525] tg3 0000:03:00.0: eth0: E=
EE is enabled
Aug  3 06:47:13 atlovav1a kernel: [626885.452974] tg3 0000:03:00.0: eth0: L=
ink is down
Aug  3 06:47:15 atlovav1a kernel: [626888.218702] tg3 0000:03:00.0: eth0: L=
ink is up at 100 Mbps, full duplex
Aug  3 06:47:15 atlovav1a kernel: [626888.218844] tg3 0000:03:00.0: eth0: F=
low control is on for TX and on for RX
Aug  3 06:47:15 atlovav1a kernel: [626888.218982] tg3 0000:03:00.0: eth0: E=
EE is enabled
Aug  3 06:51:44 atlovav1a kernel: [627156.293386] tg3 0000:03:00.0: eth0: L=
ink is down
Aug  3 06:51:46 atlovav1a kernel: [627159.123347] tg3 0000:03:00.0: eth0: L=
ink is up at 100 Mbps, full duplex
Aug  3 06:51:46 atlovav1a kernel: [627159.123491] tg3 0000:03:00.0: eth0: F=
low control is on for TX and on for RX
Aug  3 06:51:46 atlovav1a kernel: [627159.123629] tg3 0000:03:00.0: eth0: E=
EE is enabled
Aug  3 07:13:10 atlovav1a kernel: [628441.722197] tg3 0000:03:00.0: eth0: L=
ink is down
Aug  3 07:13:13 atlovav1a kernel: [628444.615548] tg3 0000:03:00.0: eth0: L=
ink is up at 100 Mbps, full duplex
Aug  3 07:13:13 atlovav1a kernel: [628444.615690] tg3 0000:03:00.0: eth0: F=
low control is on for TX and on for RX
Aug  3 07:13:13 atlovav1a kernel: [628444.615828] tg3 0000:03:00.0: eth0: E=
EE is enabled

I can't exclude the possibility it's switch problem, but I don't have acces=
s to box now and the
switch is not managed, so I'd like to try other ways first..

Could this somehow be power management related? I don't see what else PM-re=
lated could I disable
in the bios to disable this EEE stuff.. Didn't anyone met similar problem?

the system is running Centos6 with x86_64 3.0.76 kernel

thanks in advance for any reply

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

--k1lZvvs/B4yU6o8G
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.14 (GNU/Linux)

iEYEARECAAYFAlGDg04ACgkQ3xdJJrLygV7ImwCg1y6jFOip3333XsPVUxQXUefH
ycEAoJ1O4xNpE1+HjQQAUGQlBNuZrFWv
=PEqp
-----END PGP SIGNATURE-----

--k1lZvvs/B4yU6o8G--
