From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH] sched: QFQ - quick fair queue scheduler (v3)
Date: Thu, 3 Mar 2011 14:59:47 -0800
Message-ID: <20110303145947.44209d0a@nehalam>
References: <20110228171738.2cc8c9a0@nehalam>
	<1299168235.2983.116.camel@edumazet-laptop>
	<20110303084839.3ae312ed@nehalam>
	<1299191333.2547.12.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>,
	Fabio Checconi <fabio@gandalf.sssup.it>,
	Luigi Rizzo <rizzo@iet.unipi.it>, netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:39712 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759020Ab1CCW7u convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Mar 2011 17:59:50 -0500
In-Reply-To: <1299191333.2547.12.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 03 Mar 2011 23:28:53 +0100
Eric Dumazet <eric.dumazet@gmail.com> wrote:

> Le jeudi 03 mars 2011 =E0 08:48 -0800, Stephen Hemminger a =E9crit :
> > This is an implementation of the Quick Fair Queue scheduler develop=
ed
> > by Fabio Checconi. The same algorithm is already implemented in ipf=
w
> > in FreeBSD. Fabio had an earlier version developed on Linux, I just
> > cleaned it up.  Thanks to Eric Dumazet for doing the testing and
> > finding bugs.
> >=20
> > Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>
> >=20
> > ---
> > v3 - bug fixes found by Eric
> >=20
> >  include/linux/pkt_sched.h |   15=20
> >  net/sched/Kconfig         |   11=20
> >  net/sched/Makefile        |    1=20
> >  net/sched/sch_qfq.c       | 1125 +++++++++++++++++++++++++++++++++=
+++++++++++++
> >  4 files changed, 1152 insertions(+)
> >=20
>=20
>=20
> Hmm... please compile before sending your patches ;)
>=20
> You used sched_priv(sch) calls instead of qdisc_priv(sch)

Argh, forgot to do quilt --refresh
