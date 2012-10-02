From: Edivaldo de =?utf-8?b?QXJhw7pqbw==?= Pereira
	<edivaldoapereira@yahoo.com.br>
Subject: Re: Possible networking regression in 3.6.0
Date: Tue, 2 Oct 2012 15:27:17 +0000 (UTC)
Message-ID: <loom.20121002T171741-382@post.gmane.org>
References: <506955F3.8050304@googlemail.com>  <1349082950.12401.669.camel@edumazet-glaptop>  <20121001193434.GA14236@redhat.com>  <20121001.160115.1816241312626722150.davem@davemloft.net> <1349121884.12401.721.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from plane.gmane.org ([80.91.229.3]:48879 "EHLO plane.gmane.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752806Ab2JBRZX (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 2 Oct 2012 13:25:23 -0400
Received: from list by plane.gmane.org with local (Exim 4.69)
	(envelope-from <linux-netdev-2@m.gmane.org>)
	id 1TJ6DP-00052W-Iy
	for netdev@vger.kernel.org; Tue, 02 Oct 2012 19:25:04 +0200
Received: from 189.125.162.220 ([189.125.162.220])
        by main.gmane.org with esmtp (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Tue, 02 Oct 2012 19:25:03 +0200
Received: from edivaldoapereira by 189.125.162.220 with local (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Tue, 02 Oct 2012 19:25:03 +0200
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

HEric Dumazet <eric.dumazet <at> gmail.com> writes:

>=20
> On Mon, 2012-10-01 at 16:01 -0400, David Miller wrote:
> > From: Dave Jones <davej <at> redhat.com>
> > Date: Mon, 1 Oct 2012 15:34:34 -0400
> >=20
> > > On Mon, Oct 01, 2012 at 11:15:50AM +0200, Eric Dumazet wrote:
> > >  > >=20
> > >  > > $ netstat -s
> > >  > > Icmp:
> > >  > >      4 ICMP messages received
> > >  > >      4 input ICMP message failed.
> > >  > >      ICMP input histogram:
> > >  > >          echo replies: 4
> > >  >=20
> > >  > So icmp replies come back and are delivered to host instead of=
 being
> > >  > forwarded.
> > >  >=20
> > >  > I wonder if MASQUERADE broke...
> > >=20
> > > I hit something that sounds just like this a few months back..
> > > http://lists.openwall.net/netdev/2012/07/25/53
> > >=20
> > > It "went away" a few builds later, but I've seen it happen
> > > again from time to time.
> >=20
> > Yep I remembe that report.
> >=20
> > If you can find a way to more reliably trigger the case, that would
> > help us immensely.
>=20
> I am building a KMEMCHECK kernel, as a last try before my night ;)
>=20
>=20
i,

I'm facing this kind of problem, too, but it is a little different; fro=
m the=20
kvm guest I can ping the local host and any host outside my local (phys=
ical)=20
network, but cannot ping other hosts in the local (physical) net. This =
happens=20
whith guests in a virtual switch (vde) or in any bridged tun/tap. I swi=
tched=20
back to 3.5.4, for now.

Thanks
Edivaldo de Ara=C3=BAjo Pereira
