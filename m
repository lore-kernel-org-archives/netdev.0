From: Alexander Gordeev <lasaine@lvk.cs.msu.su>
Subject: Re: [PATCH V7 1/8] ntp: add ADJ_SETOFFSET mode bit
Date: Wed, 22 Dec 2010 12:58:10 +0300
Message-ID: <20101222125810.2e41b167@apollo.gnet>
References: <cover.1292512461.git.richard.cochran@omicron.at>
	<880d82bb8120f73973db27e0c48e949014b1a106.1292512461.git.richard.cochran@omicron.at>
	<AANLkTi=yGoFwYt4p_LeHtAQyYgmURspO-p57UdL0sUEZ@mail.gmail.com>
	<1292960224.2618.4.camel@work-vm>
	<AANLkTikHV-qN73Zvvvxn76vtFFKG_VNTQhF3qpqTnOrE@mail.gmail.com>
	<1292968784.2618.51.camel@work-vm>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=PGP-SHA256;
 boundary="Sig_//HgGPbBx7PbTHmzxfVUpz3d"; protocol="application/pgp-signature"
Cc: "Kuwahara,T." <6vvetjsrt26xsrzlh1z0zn4d2grdah@gmail.com>,
	Rodolfo Giometti <giometti@enneenne.com>,
	Richard Cochran <richardcochran@gmail.com>,
	linux-kernel@vger.kernel.org, linux-api@vger.kernel.org,
	netdev@vger.kernel.org, Alan Cox <alan@lxorguk.ukuu.org.uk>,
	Arnd Bergmann <arnd@arndb.de>,
	Christoph Lameter <cl@linux.com>,
	David Miller <davem@davemloft.net>,
	Krzysztof Halasa <khc@pm.waw.pl>,
	Peter Zijlstra <peterz@infradead.org>,
	Rodolfo Giometti <giometti@linux.it>,
	Thomas Gleixner <tglx@linutronix.de>
To: john stultz <johnstul@us.ibm.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1292968784.2618.51.camel@work-vm>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--Sig_//HgGPbBx7PbTHmzxfVUpz3d
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

=D0=92 Tue, 21 Dec 2010 13:59:44 -0800
john stultz <johnstul@us.ibm.com> =D0=BF=D0=B8=D1=88=D0=B5=D1=82:

> On Wed, 2010-12-22 at 06:13 +0900, Kuwahara,T. wrote:
> > On Wed, Dec 22, 2010 at 4:37 AM, john stultz <johnstul@us.ibm.com> wrot=
e:
> > > adjtimex is a linux specific interface, which is compatible but not
> > > identical to the ntp specified interfaces. The ntp client code already
> > > has Linux specific modifications, so I don't think we have to worry
> > > about 0x40 specifically being reserved by the NTP client.
> >=20
> > But struct timex is not linux-specific...
>=20
> It is if you're compiling against linux's timex.h file.=20
>=20
> We already have a number of differences compared with BSD's timex mode
> definitions:
> We have ADJ_TICK: 0x4000, which is MOD_CLKB in FreeBSD.
> We also have ADJ_OFFSET_SINGLESHOT and ADJ_OFFSET_SS_READ which allow
> adjtimex act like the original ntp_adjtime.
>=20
> The key bit is that we map the shared MOD_* definitions that the NTP
> client uses to the linux specific ADJ_* values in the linux timex.h
>=20
> However, your concern does bring up a good point: 0x40 is MOD_PPSMAX in
> BSD, and we should at-least check to make sure that the PPS code that is
> currently floating around on the lists and is in akpm's tree hasn't
> already reserved that bit.
>=20
> Rodolfo, Alexander: Any comments here?

No, it is used neither in my patches nor in the original code. The only
change my patches do to timex.h is adding hardpps().

--=20
  Alexander

--Sig_//HgGPbBx7PbTHmzxfVUpz3d
Content-Type: application/pgp-signature; name=signature.asc
Content-Disposition: attachment; filename=signature.asc

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.10 (GNU/Linux)

iQEcBAEBCAAGBQJNEcuzAAoJEElrwznyooJbqIkH/0dC5fYiv7FoTr6YFmWapDnk
rSgeRe5NeYn9yP+cUu4/TzETaChFswP6cUBpIJ1qZuCzkU58WitIi/x3mAENMGas
hztqAVrh0SB33yVtPqsbVVBsVJssH7Ox7p2TLilIeqShKG7Wf8LftpTH1v4nuMFQ
cy+qlzJGPS48HW90oJOMNrNu4zDFWGo5q11WuEQ6LPKZHpNEoODJTyV+h+IKhe0J
iCVnvEfnEQM9qQXhG68lvB/XklTIWFvP6cWLA2HiDRIKdQF74s7XcFktvXhfjGIt
tDMzMFtPsULiW3lE6350mcQiBRZhRKX/ainLUw5l13UGTbxWmq7If2mLDECxFWo=
=tfcP
-----END PGP SIGNATURE-----

--Sig_//HgGPbBx7PbTHmzxfVUpz3d--
