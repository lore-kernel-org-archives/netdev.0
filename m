From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PATCH] loop unrolling in net/sched/sch_generic.c
Date: Wed, 6 Jul 2005 03:07:56 +0200
Message-ID: <20050706010756.GV16076@postel.suug.ch>
References: <20050705173411.GK16076@postel.suug.ch> <20050705.142210.14973612.davem@davemloft.net> <20050705213355.GM16076@postel.suug.ch> <20050705.143548.28788459.davem@davemloft.net> <42CB14B2.5090601@cosmosbay.com> <20050705234104.GR16076@postel.suug.ch> <42CB2698.2080904@cosmosbay.com> <20050706005140.GT16076@postel.suug.ch> <42CB2E24.6010303@cosmosbay.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: quoted-printable
Cc: "David S. Miller" <davem@davemloft.net>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Eric Dumazet <dada1@cosmosbay.com>
Content-Disposition: inline
In-Reply-To: <42CB2E24.6010303@cosmosbay.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

* Eric Dumazet <42CB2E24.6010303@cosmosbay.com> 2005-07-06 03:04
> Thomas Graf a =E9crit :
>=20
> >>Maybe we can rewrite the whole thing without branches, examining prio=
=20
> >>from PFIFO_FAST_BANDS-1 down to 0, at least for modern cpu with=20
> >>conditional mov (cmov)
> >
> >
> >This would break the whole thing, the qdisc is supposed to try and
> >dequeue from the highest priority queue (prio=3D0) first.
> >
> >
>=20
> I still dequeue a packet from the highest priority queue.

Ahh... sorry, I misread your patch, interesting idea. I'll
be waiting for your numbers.
