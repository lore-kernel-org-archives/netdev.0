From: "Mike ." <mike-bugreport@hotmail.com>
Subject: Bug#656476: Sundance network driver (D-Link DFE-580TX) timeouts
	rendering interface unusable
Date: Mon, 23 Apr 2012 17:34:36 +0200
Message-ID: <SNT141-W23351964EC519173C84BAD96210@phx.gbl>
References: <SNT141-W58AC5ADD0BC9DE29AFA00D968E0@phx.gbl>,<1327811546.5400.291.camel@deadeye>,<CAHj3AVm8cjkj83QHGAqOji6t4uWFr6jAAADu7vLKyfEORk1LoA@mail.gmail.com>,<1327918447.2288.24.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>,<1327932311.5400.429.camel@deadeye>,<1327933736.2288.41.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>,<1327934477.5400.448.camel@deadeye>,<1327935455.2297.5.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>,<1327936900.2297.7.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>,<SNT141-W2773C07AA4E8276F3E1E4496730@phx.gbl>,<20120316220413.GA31359@burratino>
Reply-To: "Mike ." <mike-bugreport@hotmail.com>, 656476@bugs.debian.org
Mime-Version: 1.0
Content-Type: multipart/alternative;
	boundary="_13d691b2-1a1a-4d42-9ea0-326b31a9db30_"
Cc: <eric.dumazet@gmail.com>, <ben@decadent.org.uk>, <kirjanov@gmail.com>,
	<netdev@vger.kernel.org>, <benoit.mortier@opensides.be>,
	<herbert@gondor.apana.org.au>
To: <jrnieder@gmail.com>, <656476@bugs.debian.org>
Return-path: <bounce-debian-bugs-dist=glddb-debian-bugs-dist=m.gmane.org@lists.debian.org>
Resent-Message-ID: <handler.656476.B656476.133519535912454@bugs.debian.org>
In-Reply-To: <20120316220413.GA31359@burratino>
List-Post: <mailto:debian-bugs-dist@lists.debian.org>
List-Help: <mailto:debian-bugs-dist-request@lists.debian.org?subject=help>
List-Subscribe: <mailto:debian-bugs-dist-request@lists.debian.org?subject=subscribe>
List-Unsubscribe: <mailto:debian-bugs-dist-request@lists.debian.org?subject=unsubscribe>
List-Id: netdev.vger.kernel.org

--_13d691b2-1a1a-4d42-9ea0-326b31a9db30_
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable


Hi=2C

Sorry for the delay=2C couldn't test for quite some time due to some fried =
hardware=2C kernel.org bug report has been created now : https://bugzilla.k=
ernel.org/show_bug.cgi?id=3D43152

Cheers=2C

Mike.

> Date: Fri=2C 16 Mar 2012 17:04:13 -0500
> From: jrnieder@gmail.com
> To: mike-bugreport@hotmail.com
> CC: eric.dumazet@gmail.com=3B ben@decadent.org.uk=3B kirjanov@gmail.com=
=3B netdev@vger.kernel.org=3B benoit.mortier@opensides.be=3B herbert@gondor=
.apana.org.au
> Subject: Re: Sundance network driver (D-Link DFE-580TX) timeouts renderin=
g interface unusable
>=20
> Hi again=2C
>=20
> Mike . wrote:
>=20
> >> Oh well=2C we also must make sure we held np->lock in TX completion wh=
en
> >> doing our test to eventually call netif_wake_queue()=2C I missed it wa=
s
> >> released too early.
> >>
> >> here is a more complete patch.
> >
> > I applied the patch=2C recompiled the module=2C loaded it into the kern=
el and
> > started testing traffic on the interface with the following result :
> >
> > [ 1124.008030] ------------[ cut here ]------------
> > [ 1124.008101] WARNING: at /build/buildd-linux-2.6_3.2.1-2-i386-4wAPNj/=
linux-2.6-3.2.1/debian/build/source_i386_none/net/sched/sch_generic.c:255 d=
ev_watchdog+0xb1/0x104()
> > [ 1124.008201] Hardware name:
> > [ 1124.008252] NETDEV WATCHDOG: eth1 (sundance): transmit queue 0 timed=
 out
> [...]
> > After this the same repeat of transmit timeouts (as posted earlier) in =
the
> > log untill I down the interface.
>=20
> Thanks.  I assume current 3.3 release candidates behave the same way.
>=20
> Based on [2]=2C it looks like v2.6.25-rc9~99^2~24 ([NET]: Add preemption
> point in qdisc_run=2C 2008-03-28) made this easier to trip.
>=20
> As for the next step: I'd suggest posting a summary of the symptoms=2C
> which kernel versions you have tested=2C and a link to [1] at
> http://bugzilla.kernel.org/=2C product Drivers=2C component Network=2C an=
d
> letting us know the bug number so we can track it without forgetting
> what has already been learned.
>=20
> Hope that helps=2C
> Jonathan
>=20
> [1] http://thread.gmane.org/gmane.linux.network/219101
 		 	   		  =

--_13d691b2-1a1a-4d42-9ea0-326b31a9db30_
Content-Type: text/html; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable

<html>
<head>
<style><!--
.hmmessage P
{
margin:0px=3B
padding:0px
}
body.hmmessage
{
font-size: 10pt=3B
font-family:Tahoma
}
--></style></head>
<body class=3D'hmmessage'><div dir=3D'ltr'>
Hi=2C<br><br>Sorry for the delay=2C couldn't test for quite some time due t=
o some fried hardware=2C kernel.org bug report has been created now : https=
://bugzilla.kernel.org/show_bug.cgi?id=3D43152<br><br>Cheers=2C<br><br>Mike=
.<br><br><div><div id=3D"SkyDrivePlaceholder"></div>&gt=3B Date: Fri=2C 16 =
Mar 2012 17:04:13 -0500<br>&gt=3B From: jrnieder@gmail.com<br>&gt=3B To: mi=
ke-bugreport@hotmail.com<br>&gt=3B CC: eric.dumazet@gmail.com=3B ben@decade=
nt.org.uk=3B kirjanov@gmail.com=3B netdev@vger.kernel.org=3B benoit.mortier=
@opensides.be=3B herbert@gondor.apana.org.au<br>&gt=3B Subject: Re: Sundanc=
e network driver (D-Link DFE-580TX) timeouts rendering interface unusable<b=
r>&gt=3B <br>&gt=3B Hi again=2C<br>&gt=3B <br>&gt=3B Mike . wrote:<br>&gt=
=3B <br>&gt=3B &gt=3B&gt=3B Oh well=2C we also must make sure we held np-&g=
t=3Block in TX completion when<br>&gt=3B &gt=3B&gt=3B doing our test to eve=
ntually call netif_wake_queue()=2C I missed it was<br>&gt=3B &gt=3B&gt=3B r=
eleased too early.<br>&gt=3B &gt=3B&gt=3B<br>&gt=3B &gt=3B&gt=3B here is a =
more complete patch.<br>&gt=3B &gt=3B<br>&gt=3B &gt=3B I applied the patch=
=2C recompiled the module=2C loaded it into the kernel and<br>&gt=3B &gt=3B=
 started testing traffic on the interface with the following result :<br>&g=
t=3B &gt=3B<br>&gt=3B &gt=3B [ 1124.008030] ------------[ cut here ]-------=
-----<br>&gt=3B &gt=3B [ 1124.008101] WARNING: at /build/buildd-linux-2.6_3=
.2.1-2-i386-4wAPNj/linux-2.6-3.2.1/debian/build/source_i386_none/net/sched/=
sch_generic.c:255 dev_watchdog+0xb1/0x104()<br>&gt=3B &gt=3B [ 1124.008201]=
 Hardware name:<br>&gt=3B &gt=3B [ 1124.008252] NETDEV WATCHDOG: eth1 (sund=
ance): transmit queue 0 timed out<br>&gt=3B [...]<br>&gt=3B &gt=3B After th=
is the same repeat of transmit timeouts (as posted earlier) in the<br>&gt=
=3B &gt=3B log untill I down the interface.<br>&gt=3B <br>&gt=3B Thanks.  I=
 assume current 3.3 release candidates behave the same way.<br>&gt=3B <br>&=
gt=3B Based on [2]=2C it looks like v2.6.25-rc9~99^2~24 ([NET]: Add preempt=
ion<br>&gt=3B point in qdisc_run=2C 2008-03-28) made this easier to trip.<b=
r>&gt=3B <br>&gt=3B As for the next step: I'd suggest posting a summary of =
the symptoms=2C<br>&gt=3B which kernel versions you have tested=2C and a li=
nk to [1] at<br>&gt=3B http://bugzilla.kernel.org/=2C product Drivers=2C co=
mponent Network=2C and<br>&gt=3B letting us know the bug number so we can t=
rack it without forgetting<br>&gt=3B what has already been learned.<br>&gt=
=3B <br>&gt=3B Hope that helps=2C<br>&gt=3B Jonathan<br>&gt=3B <br>&gt=3B [=
1] http://thread.gmane.org/gmane.linux.network/219101<br></div> 		 	   		  =
</div></body>
</html>=

--_13d691b2-1a1a-4d42-9ea0-326b31a9db30_--
