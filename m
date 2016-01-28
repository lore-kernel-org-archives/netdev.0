From: Nikola Ciprich <nikola.ciprich@linuxbox.cz>
Subject: Re: Supermicro AOC-STGN-i2S w intel 82599ES on Brocade ICX6610 -
 random link failures
Date: Thu, 28 Jan 2016 09:48:23 +0100
Message-ID: <20160128084823.GE10986@pcnci.linuxbox.cz>
References: <20160125100851.GA7545@nbnik.linuxbox.cz>
 <56A5FC7B.3020803@gmail.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="vv4Sf/kQfcwinyKX"
Cc: netdev <netdev@vger.kernel.org>, nik@linuxbox.cz,
	Stanislav Schattke <schattke@linuxbox.cz>,
	Nikola Ciprich <nikola.ciprich@linuxbox.cz>
To: zhuyj <zyjzyj2000@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gwu.lbox.cz ([62.245.111.132]:54591 "EHLO gwu.lbox.cz"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S965152AbcA1Is0 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 28 Jan 2016 03:48:26 -0500
Content-Disposition: inline
In-Reply-To: <56A5FC7B.3020803@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--vv4Sf/kQfcwinyKX
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable


Hello Zhu,

I'm sorry for late reply.. I can test the patch, but if I understand
correctly, it deals with bonding issue, not (lower level) interface
link problems no? Bonding works well for me, I'm trying to find
out why link failures occur..

please correct me if I'm wrong

thanks=20

nik





On Mon, Jan 25, 2016 at 06:44:11PM +0800, zhuyj wrote:
> https://www.mail-archive.com/netdev@vger.kernel.org/msg94109.html
>=20
> Maybe this link can help you. If work, please let me know.
>=20
> Thanks a lot.
> Zhu Yanjun
>=20
> On 01/25/2016 06:08 PM, Nikola Ciprich wrote:
> >Hello netdev readers,
> >
> >I'd like to consult following problem we're dealing with:
> >
> >I have a cluster of three nodes connected to stacked Brocade ICX6610
> >switches using bonded AOC-STGN-i2S adapters (they're using 82599ES
> >chipsets).
> >
> >The problem is, I see random link failures on practically all
> >interfaces. Link always goes down for very short time, then adapter
> >is reset and link goes up again.
> >
> >Here's dmesg snippet:
> >
> >[Jan22 22:09] ixgbe 0000:03:00.0 eth0: NIC Link is Down
> >[  +0.005610] ixgbe 0000:03:00.0 eth0: initiating reset to clear Tx work=
 after link loss
> >[  +0.012792] bond0: link status definitely down for interface eth0, dis=
abling it
> >[  +1.105826] ixgbe 0000:03:00.0 eth0: Reset adapter
> >[  +0.307518] ixgbe 0000:03:00.0 eth0: detected SFP+: 3
> >[  +0.145881] ixgbe 0000:03:00.0 eth0: NIC Link is Up 10 Gbps, Flow Cont=
rol: RX/TX
> >
> >since I'm using bonding, it doesn't disrupt traffic, but I'd still like =
to
> >resolve it. We're using 5m passive SFP cables, we tried replacing one wi=
th 3m
> >piece, to no avail.
> >
> >all three boxes are supermicro X10DRW, running vanilla x86_64 4.0.5 kern=
el (I'll upgrade it to 4.1.16 soon)
> >
> >we were using broadcom adapter before and they were working without such=
 problems
> >(except for one particular port, which showed mysterious packet drops ev=
ery few
> >months, thats why we switched to intel-based adapters), so I think cable=
s and switches
> >should be fine, but I'm not sure of course
> >
> >I think I've seen similar problems and they were PM related, but I'm not=
 sure..
> >
> >anyone seen similar problem?
> >
> >or some tips on how could I debug it?
> >
> >If I could provide more information, please let me know
> >
> >BR
> >
> >nik
> >
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

--vv4Sf/kQfcwinyKX
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.14 (GNU/Linux)

iEYEARECAAYFAlap1dcACgkQ3xdJJrLygV4N3QCfavdRarNLZYykLQTpMmvmtkWE
pXEAn3YMJSGclnUTcPFbA5Nk3BsGUUF5
=LXhp
-----END PGP SIGNATURE-----

--vv4Sf/kQfcwinyKX--
