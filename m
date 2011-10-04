From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [RFC] iproute2: add br command
Date: Tue, 4 Oct 2011 16:00:36 -0700
Message-ID: <20111004160036.59e1ea03@nehalam.linuxnetplumber.net>
References: <CAGXs5wWeFcyHQ4vO562pTOdqLNEKrJwES3W_hFF_M2reNoe1rA@mail.gmail.com>
	<20111004093413.2f6bbd67@nehalam.linuxnetplumber.net>
	<m27h4klmls.fsf@firstfloor.org>
	<20111004140754.0e677941@nehalam.linuxnetplumber.net>
	<1317766638.21658.11.camel@w-sridhar.beaverton.ibm.com>
	<CAHXqBF+gXg=EAOm4F_qGWhND6EsZHzoamE8fRX6eqe1p1zU-SQ@mail.gmail.com>
	<20111004154244.3530f21c@nehalam.linuxnetplumber.net>
	<1317768847.21658.16.camel@w-sridhar.beaverton.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: =?UTF-8?B?TWljaGHFgiBNaXJvc8WCYXc=?= <mirqus@gmail.com>,
	Andi Kleen <andi@firstfloor.org>,
	Kevin Wilson <wkevils@gmail.com>, netdev@vger.kernel.org
To: Sridhar Samudrala <sri@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:39775 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933137Ab1JDXAj convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 Oct 2011 19:00:39 -0400
In-Reply-To: <1317768847.21658.16.camel@w-sridhar.beaverton.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 04 Oct 2011 15:54:07 -0700
Sridhar Samudrala <sri@us.ibm.com> wrote:

> On Tue, 2011-10-04 at 15:42 -0700, Stephen Hemminger wrote:
> > On Wed, 5 Oct 2011 00:32:31 +0200
> > Micha=C5=82 Miros=C5=82aw <mirqus@gmail.com> wrote:
> >=20
> > > 2011/10/5 Sridhar Samudrala <sri@us.ibm.com>:
> > > > On Tue, 2011-10-04 at 14:07 -0700, Stephen Hemminger wrote:
> > > >> On Tue, 04 Oct 2011 09:58:55 -0700
> > > >> Andi Kleen <andi@firstfloor.org> wrote:
> > > >> > Stephen Hemminger <shemminger@vyatta.com> writes:
> > > >> > > This adds a new 'br' command which is the bridging equival=
ent of
> > > >> > > the ip command. More of a demo of how to use netlink and b=
ridging
> > > >> > > at this point.
> > > >> > Please name it "bridge", not "br"
> > > >> Ok, but it breaks the existing pattern.
> > > > Is this supposed to replace brctl utility?
> > > >
> > > > Can we add/delete a bridge and add/delete interfaces to a bridg=
e using
> > > > this command?
> > > >
> > > > If so, why not make it
> > > >   ip bridge add/del <brname>
> > > >   ip bridge addif/delif <brname> <ifname>
> > >=20
> > > I'll add one more idea:
> > >=20
> > > ip link add/del <brname> type bridge
> > > ip bridge add/del <brname> <ifname>
> > > ip bridge fdb ...
> >=20
> > In 3.0 you can already do:
> > # ip link add dev br3 type bridge
> > # ip link set dev eth3 master br3
>=20
> I just pulled iproute2 tree from=20
> git://github.com/shemminger/iproute2.git
>=20
> But i don't see these updates there. Isn't this your latest iproute2 =
tree?

There is no special code for doing ip link stuff. it just works with
correct kernel.
=20
> >=20
> > I see no reason to add 'ip bridge' syntax wrappers.
>=20
> If we can make all bridge related commands use 'ip bridge' prefix ,=20
> i think we wouldn't need a new 'br' command.

Maybe but there is no IP protocol function or requirement for bridging.
