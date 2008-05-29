From: pomac@vapor.com
Subject: Re: [ipv6] Odd behaviour...
Date: Thu, 29 May 2008 14:20:16 +0200
Message-ID: <20080529122016.GG11812@pomac.netswarm.net>
References: <20080529084157.GD11812@pomac.netswarm.net> <20080529.182853.67833046.yoshfuji@linux-ipv6.org> <20080529100822.GF11812@pomac.netswarm.net> <20080529.194616.51574992.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: akpm@linux-foundation.org, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: YOSHIFUJI Hideaki / =?utf-8?B?5ZCJ6Jek6Iux5piO?=
	<yoshfuji@linux-ipv6.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vapor.com ([85.114.133.49]:42774 "EHLO mail.vapor.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751349AbYE2MUY (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 29 May 2008 08:20:24 -0400
Content-Disposition: inline
In-Reply-To: <20080529.194616.51574992.yoshfuji@linux-ipv6.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, May 29, 2008 at 07:46:16PM +0900, YOSHIFUJI Hideaki / =E5=90=89=
=E8=97=A4=E8=8B=B1=E6=98=8E wrote:
> In article <20080529100822.GF11812@pomac.netswarm.net> (at Thu, 29 Ma=
y 2008 12:08:22 +0200), pomac@vapor.com says:
>=20
> > On Thu, May 29, 2008 at 06:28:53PM +0900, YOSHIFUJI Hideaki / =E5=90=
=89=E8=97=A4=E8=8B=B1=E6=98=8E wrote:
> > > In article <20080529084157.GD11812@pomac.netswarm.net> (at Thu, 2=
9 May 2008 10:41:57 +0200), pomac@vapor.com says:
> > >=20
> > > > On Thu, May 29, 2008 at 12:27:29AM -0700, Andrew Morton wrote:
> > > > > On Tue, 27 May 2008 00:58:30 +0200 Ian Kumlien <pomac@vapor.c=
om> wrote:
> > > > >=20
> > > > > > Hi,=20
> > > > > >=20
> > > > > > I just recently acquired a new ipv6 tunnel since my two pre=
vious brokers
> > > > > > has gone out of business. I now use hurricane electrics tun=
nel since i
> > > > > > have really good ping times to it's node in Amsterdam.
> > > > > >=20
> > > > > > Anyways, i have setup a local network tunnel and enabled fo=
rwarding.
> > > > > >=20
> > > > > > After about 300 seconds, it all stops working. I have to di=
sable and
> > > > > > re-enable it on the firewall/router to get it working again=
=2E
> > > > > >=20
> > > > > > tcpdump shows the router/firewall doing odd things like:
> > > > > > (i renamed my host to piv6)
> > > > > >=20
> > > > > > 00:48:14.294173 IP6 piv6 > igloo.stacken.kth.se: ICMP6, ech=
o request,
> > > > > > seq 321, length 64
> > > > > >=20
> > > > > > 00:48:14.341288 IP6 igloo.stacken.kth.se > piv6: ICMP6, ech=
o reply, seq
> > > > > > 321, length 64
> > > > > >=20
> > > > > > 00:48:14.341317 IP6 fe80::55e4:1b90 > igloo.stacken.kth.se:=
 ICMP6,
> > > > > > redirect, piv6 to piv6, length 160
> > > > > >=20
> > > > > > 00:48:14.341332 IP6 igloo.stacken.kth.se > piv6: ICMP6, ech=
o reply, seq
> > > > > > 321, length 64
> > > > > > ---
> > > > > >=20
> > > > > > fe80::55e4::1b90 is the local ip of the ipv6 tunnel.
> > > > > > (note: the packet never arrives at it's destination)
> > > > > >=20
> > > > > > Any ideas of what could be going wrong?		=09
> > > > >=20
> > > > > (cc netdev - afaik linux-net is kind of dead)
> > > >=20
> > > > Thanks, i knew i missed something, -net was the one that was al=
ready in
> > > > my email client so... =3D)
> > > >=20
> > > > > What kernel version are you running?
> > > >=20
> > > > The router/fw is running 2.6.25.1, the client is running 2.6.25=
=2E4
> > > >=20
> > > > Any additional information i should provide?
> > >=20
> > > How do you assign the address?
> >=20
> > On the router/fw there is a sit tunnel thats started with 'ip'.
> >=20
> > The clients get their addresses by radvd which only uses a local
> > interface on the router/fw...
>=20
> Please draw w a network topology figure.

It's very basic...=20

client -> router/fw -tap-tunnel-> -hurricane-electric-> internet.

(the firewall/router is my normal ipv4 firewall but for ipv6 it acts as
a router, thus the "router/fw" or "firewall/router".

but, router/fw -tap-tunnel-> -hurricane->electric-> internet. always
works, and outgoing communications always works. This is only a problem
for incoming communications.

> --yoshfuji
