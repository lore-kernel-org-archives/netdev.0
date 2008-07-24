From: Ignacy Gawedzki <lkml@qult.net>
Subject: Re: TUN/TAP hacking
Date: Thu, 24 Jul 2008 10:34:47 +0200
Message-ID: <20080724083447.GA24392@zenon.in.qult.net>
References: <20080723235514.GA8992@zenon.in.qult.net> <4887E818.4020305@isomerica.net> <20080724085006.1163d122@catlap>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-2
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: NetDev <netdev@vger.kernel.org>
To: Marek Kierdelewicz <marek@piasta.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from qult.net ([82.238.217.46]:33451 "EHLO slartibartfast.qult.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750710AbYGXJP3 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 24 Jul 2008 05:15:29 -0400
Content-Disposition: inline
In-Reply-To: <20080724085006.1163d122@catlap>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jul 24, 2008 at 08:50:06AM +0200, thus spake Marek Kierdelewicz=
:
> Hi Ignacy & netdev,
>=20
> > I thought I'd be able to use the TAP interfaces to create some sort
> > of a network emulator.  For a start I just "bridged" two tap
> > interfaces, much in the same way as the example of br_select.c from
> > http://vtun.sf.net , assigned both interfaces different IPv4
> > addresses (both with a /32 prefix),
>=20
> As far as I understand you're trying to bridge two interfaces of the
> same host. It's no good for a test network, because local traffic
> (from/to the same host) will always be forwarded locally (via lo?) an=
d
> will never reach any ethX or tapX interface (not without kernel
> hacking).

Well... surely this would happen without a little hack as you say.  Her=
e I
thought that I could use multiple routing tables + ip rules + iptables,=
 but
I'm not 100% convinced that locally generated packets could be marked w=
ith
iptables and directed by ip rules to the correct routing table (which w=
ould
make no mention of the destination address as a local interface).  I ma=
de a
few tests with ping (using -I to specify the outgoing interface), but A=
RP
resolution failed and I see no way to force the destination stack reply=
 to
echo-requests using a specific routing table (as I intended to do for n=
ormal
applications).

>           There's another way... You can use QEMU[1]/KQEMU[2]/KVM[3] =
for
> guest system virtualization with options that create tapX interfaces
> on host and ethX on guests. Then you can bridge taps the way you want
> (even with eths on your host system) as described in [4][5]. For gues=
t
> system I'd recommend openwrt kamikaze[6]. It's small in terms of syst=
em
> image size and memory consumption so you can build a complex virtual
> network of 10+ hosts using only 200MB of disk space and 320MB of ram.

Yeah, I also thought about that one, but if I could avoid the additiona=
l
overhead, it would be better.

> Cheers,
> Marek Kierdelewicz

Dzi=EAki anyway. =3D)

--=20
NO CARRIER
