From: Marc Haber <mh+linux-kernel-bugs@zugschlus.de>
Subject: Re: [Bug #15042] socket(PF_INET6 hangs when ipv6 not yet
	initialized
Date: Sun, 14 Feb 2010 07:20:15 +0100
Message-ID: <20100214062015.GA16912@torres.zugschlus.de>
References: <pYFNu11z2aM.A.pJH.CZMXLB@chimera> <q60Z28d_9yH.A.oqH.NZMXLB@chimera> <2375c9f91001270110t2a8d08b8n4578df310a6129@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "Rafael J. Wysocki" <rjw@sisk.pl>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	Kernel Testers List <kernel-testers@vger.kernel.org>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>
To: =?utf-8?Q?Am=C3=A9rico?= Wang <xiyou.wangcong@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <2375c9f91001270110t2a8d08b8n4578df310a6129@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

sorry for the late reply.

On Wed, Jan 27, 2010 at 05:10:44PM +0800, Am=C3=A9rico Wang wrote:
> On Mon, Jan 25, 2010 at 6:23 AM, Rafael J. Wysocki <rjw@sisk.pl> wrot=
e:
> > This message has been generated automatically as a part of a report
> > of regressions introduced between 2.6.31 and 2.6.32.
> >
> > The following bug entry is on the current list of known regressions
> > introduced between 2.6.31 and 2.6.32. =C2=A0Please verify if it sti=
ll should
> > be listed and let me know (either way).
> >
> >
> > Bug-Entry =C2=A0 =C2=A0 =C2=A0 : http://bugzilla.kernel.org/show_bu=
g.cgi?id=3D15042
> > Subject =C2=A0 =C2=A0 =C2=A0 =C2=A0 : socket(PF_INET6 hangs when ip=
v6 not yet initialized
> > Submitter =C2=A0 =C2=A0 =C2=A0 : Marc Haber <mh+linux-kernel@zugsch=
lus.de>
> > Date =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0: 2010-01-10 14:28 (1=
5 days old)
> > References =C2=A0 =C2=A0 =C2=A0: http://marc.info/?l=3Dlinux-kernel=
&m=3D126313553029280&w=3D4
> >
>=20
> (Adding net-dev into Cc)
>=20
> Hi, Marc,
>=20
> Sorry, I don't really understand your description of the problem, you=
r mean
> your ssh hangs on socket PF_INET6 for 30 seconds?

No, it hangs on socket PF_INET6 indefinetely (max time I waited was
like ten minutes), ignoring SIGTERM while hanging. This does only
happen if the sshd is started within seconds of the ipv6 module being
loaded (or the Interface being brought up), so I guess that the kernel
needs to be in a state where it already thinks that it has IPv6 but
hasn't completed autoconfiguration yet.

To obtain an strace, I had to use timeout --signal=3D9 30. The
virtualbox process this happens inside takes all host CPU while the
ssh process hangs.

> Have you enabled CONFIG_DETECT_SOFTLOCKUP for your kernel?

yes, that's enabled.

Greetings
Marc

--=20
-----------------------------------------------------------------------=
------
Marc Haber         | "I don't trust Computers. They | Mailadresse im He=
ader
Mannheim, Germany  |  lose things."    Winona Ryder | Fon: *49 621 7273=
9834
Nordisch by Nature |  How to make an American Quilt | Fax: *49 3221 232=
3190

Bitte beachten Sie, da=C3=9F dem [m.E. grundgesetzwidrigen] Gesetz zur
Vorratsdatenspeicherung zufolge, seit dem 1. Januar 2008 jeglicher
elektronische Kontakt (E-Mail, Telefongespr=C3=A4che, SMS, Internet-
Telefonie, Mobilfunk, Fax) mit mir oder anderen Nutzern verdachts-
unabh=C3=A4ngig f=C3=BCr den automatisierten geheimen Zugriff durch Str=
afver-
folgungs- u. Polizeivollzugsbeh=C3=B6rden, die Bundesanstalt f=C3=BCr F=
inanz-
dienstleistungsaufsicht, Zollkriminal- und Zollfahndungs=C3=A4mter,die
Zollverwaltung zur Schwarzarbeitsbek=C3=A4mpfung, Notrufabfragestellen,
Verfassungsschutzbeh=C3=B6rden, den Milit=C3=A4rischen Abschirmdienst, =
Bundes-
nachrichtendienst sowie 52 Staaten wie beispielsweise Aserbeidschan
oder die USA sechs Monate lang gespeichert wird, einschlie=C3=9Flich de=
r
Kommunikation mit Berufsgeheimnistr=C3=A4gern wie =C3=84rzten, Journali=
sten und
Anw=C3=A4lten. Mehr Infos zur totalen Protokollierung Ihrer Kommunikati=
ons-
daten auf www.vorratsdatenspeicherung.de. (leicht ver=C3=A4ndert =C3=BC=
bernommen
kopiert von www.lawblog.de)
