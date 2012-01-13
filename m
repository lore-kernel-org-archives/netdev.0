From: "John A. Sullivan III" <jsullivan@opensourcedevel.com>
Subject: Re: forcedeth doesn't pass traffic (3.0.x kernel and earliers)
Date: Fri, 13 Jan 2012 13:34:55 -0500
Message-ID: <1326479695.31393.326.camel@denise.theartistscloset.com>
References: <201112102226.31546.a.miskiewicz@gmail.com>
	 <201112102231.31206.a.miskiewicz@gmail.com>
	 <201201131833.29727.a.miskiewicz@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Arkadiusz =?UTF-8?Q?Mi=C5=9Bkiewicz?= <a.miskiewicz@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout.perfora.net ([74.208.4.195]:63358 "EHLO mout.perfora.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753181Ab2AMSfC convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 Jan 2012 13:35:02 -0500
In-Reply-To: <201201131833.29727.a.miskiewicz@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2012-01-13 at 18:33 +0100, Arkadiusz Mi=C5=9Bkiewicz wrote:
> On Saturday 10 of December 2011, Arkadiusz Mi=C5=9Bkiewicz wrote:
> > On Saturday 10 of December 2011, Arkadiusz Mi=C5=9Bkiewicz wrote:
> > > Hello,
> > >=20
> > > I have few supermicro machines connected to edge-core switch usin=
g 1Gbps
> > > uplink. The problem is that after boot I have to restart net to g=
et
> > > network card pass traffic. The problem is only with forcedeth net=
work
> > > cards. It happens on different supermicro servers and it happens =
for as
> > > far as I can remember (so, 2.6.3x kernels, too). Currently I'm on=
 3.0.13.
> > >=20
> > > Logs below show state after fresh boot where network traffic does=
n't get
> > > through. Note that it shows that link is up but still - traffic d=
oesn't
> > > get passed. tcpdump on eth0 interface sees only traffic initiated=
 from
> > > this server and no traffic from outside.
> > >=20
> > > Tried to set every offload (via ethtool -K) to off but that didn'=
t help.
> > >=20
> > > I have to make:
> > > ip link set eth0 down; ip link set eth0 up
> > > wait few second and then traffic starts to get passed. When I do =
that
> > > this shows in dmesg: [ 1058.266480] forcedeth 0000:00:08.0: irq 4=
0 for
> > > MSI/MSI-X
> > > [ 1069.163238] eth0: no IPv6 routers present
> >=20
> > One more note. This doesn't always happens like that. Sometimes I b=
oot
> > and I get link working, traffic gets passed fine:
>=20
<snip>
We have noticed similar behavior on some of our SuperMicro systems.  It
was worse for us; the interfaces would work fine on boot but then
inexplicably stop after weeks of running causing production outages.  W=
e
simply stopped using them - John
