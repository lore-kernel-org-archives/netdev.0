From: Sridhar Samudrala <sri@us.ibm.com>
Subject: Re: [RFC] iproute2: add br command
Date: Tue, 04 Oct 2011 15:54:07 -0700
Message-ID: <1317768847.21658.16.camel@w-sridhar.beaverton.ibm.com>
References: <CAGXs5wWeFcyHQ4vO562pTOdqLNEKrJwES3W_hFF_M2reNoe1rA@mail.gmail.com>
	 <20111004093413.2f6bbd67@nehalam.linuxnetplumber.net>
	 <m27h4klmls.fsf@firstfloor.org>
	 <20111004140754.0e677941@nehalam.linuxnetplumber.net>
	 <1317766638.21658.11.camel@w-sridhar.beaverton.ibm.com>
	 <CAHXqBF+gXg=EAOm4F_qGWhND6EsZHzoamE8fRX6eqe1p1zU-SQ@mail.gmail.com>
	 <20111004154244.3530f21c@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: =?UTF-8?Q?Micha=C5=82_Miros=C5=82aw?= <mirqus@gmail.com>,
	Andi Kleen <andi@firstfloor.org>,
	Kevin Wilson <wkevils@gmail.com>, netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e36.co.us.ibm.com ([32.97.110.154]:33840 "EHLO
	e36.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933158Ab1JDWyJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 Oct 2011 18:54:09 -0400
Received: from d03relay01.boulder.ibm.com (d03relay01.boulder.ibm.com [9.17.195.226])
	by e36.co.us.ibm.com (8.14.4/8.13.1) with ESMTP id p94MlIte009272
	for <netdev@vger.kernel.org>; Tue, 4 Oct 2011 16:47:18 -0600
Received: from d03av06.boulder.ibm.com (d03av06.boulder.ibm.com [9.17.195.245])
	by d03relay01.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id p94Ms8ti165290
	for <netdev@vger.kernel.org>; Tue, 4 Oct 2011 16:54:08 -0600
Received: from d03av06.boulder.ibm.com (loopback [127.0.0.1])
	by d03av06.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id p94Ms8gI021063
	for <netdev@vger.kernel.org>; Tue, 4 Oct 2011 16:54:08 -0600
In-Reply-To: <20111004154244.3530f21c@nehalam.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2011-10-04 at 15:42 -0700, Stephen Hemminger wrote:
> On Wed, 5 Oct 2011 00:32:31 +0200
> Micha=C5=82 Miros=C5=82aw <mirqus@gmail.com> wrote:
>=20
> > 2011/10/5 Sridhar Samudrala <sri@us.ibm.com>:
> > > On Tue, 2011-10-04 at 14:07 -0700, Stephen Hemminger wrote:
> > >> On Tue, 04 Oct 2011 09:58:55 -0700
> > >> Andi Kleen <andi@firstfloor.org> wrote:
> > >> > Stephen Hemminger <shemminger@vyatta.com> writes:
> > >> > > This adds a new 'br' command which is the bridging equivalen=
t of
> > >> > > the ip command. More of a demo of how to use netlink and bri=
dging
> > >> > > at this point.
> > >> > Please name it "bridge", not "br"
> > >> Ok, but it breaks the existing pattern.
> > > Is this supposed to replace brctl utility?
> > >
> > > Can we add/delete a bridge and add/delete interfaces to a bridge =
using
> > > this command?
> > >
> > > If so, why not make it
> > >   ip bridge add/del <brname>
> > >   ip bridge addif/delif <brname> <ifname>
> >=20
> > I'll add one more idea:
> >=20
> > ip link add/del <brname> type bridge
> > ip bridge add/del <brname> <ifname>
> > ip bridge fdb ...
>=20
> In 3.0 you can already do:
> # ip link add dev br3 type bridge
> # ip link set dev eth3 master br3

I just pulled iproute2 tree from=20
git://github.com/shemminger/iproute2.git

But i don't see these updates there. Isn't this your latest iproute2 tr=
ee?
=20
>=20
> I see no reason to add 'ip bridge' syntax wrappers.

If we can make all bridge related commands use 'ip bridge' prefix ,=20
i think we wouldn't need a new 'br' command.

Thanks
Sridhar
