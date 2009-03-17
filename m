From: "Gerhard Pircher" <gerhard_pircher@gmx.net>
Subject: Re: 3c59x: shared interrupt problem
Date: Tue, 17 Mar 2009 10:37:55 +0100
Message-ID: <20090317093755.24300@gmx.net>
References: <20090310081628.GA3217@newton.mathematik.tu-chemnitz.de>
 <20090310145542.499128ef.akpm@linux-foundation.org>
 <20090311113815.GB26526@newton.mathematik.tu-chemnitz.de>
 <20090313.155116.183062617.davem@davemloft.net>
 <20090314140841.GA17629@bayes.mathematik.tu-chemnitz.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, shemminger@vyatta.com,
	akpm@linux-foundation.org
To: Steffen Klassert <klassert@mathematik.tu-chemnitz.de>,
	davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.gmx.net ([213.165.64.20]:40508 "HELO mail.gmx.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S1754313AbZCQJh6 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 17 Mar 2009 05:37:58 -0400
In-Reply-To: <20090314140841.GA17629@bayes.mathematik.tu-chemnitz.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


-------- Original-Nachricht --------
> Datum: Sat, 14 Mar 2009 15:08:41 +0100
> Von: Steffen Klassert <klassert@mathematik.tu-chemnitz.de>
> An: David Miller <davem@davemloft.net>
> CC: akpm@linux-foundation.org, shemminger@vyatta.com, gerhard_pircher=
@gmx.net, netdev@vger.kernel.org
> Betreff: Re: 3c59x: shared interrupt problem

> On Fri, Mar 13, 2009 at 03:51:16PM -0700, David Miller wrote:
> > > #### ChangeSet ####
> > > 2003-05-19 10:27:49-07:00, akpm@digeo.com=20
> > >   [PATCH] 3c59x irqreturn fix
> > >  =20
> > >   Apparently boomerang_interrupt() is generating lots of "nobody
> > >   cared" warnings - one per packet it seems.  Frankly, I don't ha=
ve
> > >   a clue why.
> > >  =20
> > >   These are ancient cards and the driver is otherwise stable, so
> > >   just change it to return IRQ_HANDLED and move on...
> >=20
> > So basically it's a band-aid because we didn't investigate why
> > this happens.
> >=20
> > I think we should put the change in, and then look into things
> > properly if users report this issue again.
> >=20
>=20
> Gerhard reported at least one of these "nobody cared" messages at
> shutdown after applying this change. He wanted to provide us with
> further informations about this issue next week. Best would be to put
> it in together with a fix.
> So I would suggest to wait, perhaps we can fix it with his
> informations.
Okay, here's a small status update in order to show that I'm really
doing something. :)
Increasing the value of vortex_debug doesn't really help. It slows
down the network transfer too much to trigger the bug. Does somebody
know where to insert some printks in the driver to get a useful debug
output?
Bisecting shows that even v2.6.26-rc1 fails. But I have a v2.6.27-rc7
image that works fine!? Looks like I have to put more effort in
bisecting.

Gerhard
--=20
Psssst! Schon vom neuen GMX MultiMessenger geh=F6rt? Der kann`s mit all=
en: http://www.gmx.net/de/go/multimessenger01
