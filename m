From: Wolfgang Walter <linux@stwm.de>
Subject: Re: kernel >= 4.0: crashes when using traceroute6 with isatap
Date: Thu, 07 May 2015 00:11:20 +0200
Message-ID: <1489362.AtetvSCXN1@h2o.as.studentenwerk.mhn.de>
References: <1770409.aMESoOv08f@h2o.as.studentenwerk.mhn.de> <1958390.Ugr57PpLDS@h2o.as.studentenwerk.mhn.de> <CAM_iQpWei83_pEoiDWKvHHaj02_D6WGEUHYfEJWM05-RuN3CEw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: LKML <linux-kernel@vger.kernel.org>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>
To: Cong Wang <xiyou.wangcong@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAM_iQpWei83_pEoiDWKvHHaj02_D6WGEUHYfEJWM05-RuN3CEw@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Am Mittwoch, 6. Mai 2015, 11:15:18 schrieben Sie:
> (Cc'ing netdev.)
>=20
> On Sat, May 2, 2015 at 5:29 AM, Wolfgang Walter <linux@stwm.de> wrote=
:
> > Am Samstag, 2. Mai 2015, 02:16:36 schrieb Wolfgang Walter:
> >> Hello,
> >>=20
> >> kernel 4.0 (and 4.0.1) crashes immediately when I use traceroute6 =
with an
> >> isatap-tunnel.
> >=20
> > I did some further tests. To trigger the crash you need
> >=20
> > * isatap-tunnel (probably any sit-tunnel will do it)
> > * raw-socket
> > * udp
> >=20
> > Using icmpv6 or tcp i.e. does not trigger it.
>=20
> Do you have a script to reproduce it?
>=20
>=20
> Thanks for the bug report!

You need a isatap-server with say ipv4-address $X

Then, on host with 4.0, start isatapd: isatapd --mtu 1280 $X=20

then do

	traceroute6 www.google.de

Regards,
--=20
Wolfgang Walter
Studentenwerk M=FCnchen
Anstalt des =F6ffentlichen Rechts
