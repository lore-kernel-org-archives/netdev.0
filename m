From: Wolfgang Walter <linux@stwm.de>
Subject: Re: kernel >= 4.0: crashes when using traceroute6 with isatap
Date: Thu, 07 May 2015 00:04:39 +0200
Message-ID: <2723870.nq54KKjWkm@h2o.as.studentenwerk.mhn.de>
References: <1770409.aMESoOv08f@h2o.as.studentenwerk.mhn.de> <CAM_iQpWei83_pEoiDWKvHHaj02_D6WGEUHYfEJWM05-RuN3CEw@mail.gmail.com> <1430939400.14545.65.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Cong Wang <xiyou.wangcong@gmail.com>,
	Vlad Yasevich <vyasevich@gmail.com>,
	LKML <linux-kernel@vger.kernel.org>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1430939400.14545.65.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Am Mittwoch, 6. Mai 2015, 12:10:00 schrieb Eric Dumazet:
> On Wed, 2015-05-06 at 11:15 -0700, Cong Wang wrote:
> > (Cc'ing netdev.)
> >=20
> > On Sat, May 2, 2015 at 5:29 AM, Wolfgang Walter <linux@stwm.de> wro=
te:
> > > Am Samstag, 2. Mai 2015, 02:16:36 schrieb Wolfgang Walter:
> > >> Hello,
> > >>=20
> > >> kernel 4.0 (and 4.0.1) crashes immediately when I use traceroute=
6 with
> > >> an
> > >> isatap-tunnel.
> > >=20
> > > I did some further tests. To trigger the crash you need
> > >=20
> > > * isatap-tunnel (probably any sit-tunnel will do it)
> > > * raw-socket
> > > * udp
> > >=20
> > > Using icmpv6 or tcp i.e. does not trigger it.
> >=20
> > Do you have a script to reproduce it?
> >=20
> >=20
> > Thanks for the bug report!
> > --
>=20
> Please Wolfgang try to revert 32dce968dd987adfb0c00946d78dad9154f6475=
9
> ("ipv6: Allow for partial checksums on non-ufo packets")

Indeed, that fixes the problem.

Regards
--=20
Wolfgang Walter
Studentenwerk M=FCnchen
Anstalt des =F6ffentlichen Rechts
