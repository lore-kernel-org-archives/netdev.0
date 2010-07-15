From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: oops in tcp_xmit_retransmit_queue() w/ v2.6.32.15
Date: Thu, 15 Jul 2010 14:05:28 +0200
Message-ID: <1279195528.2496.2.camel@edumazet-laptop>
References: <4C358AAA.9080400@kernel.org>
	 <alpine.DEB.2.00.1007111825510.15736@melkinpaasi.cs.helsinki.fi>
	 <4C3EF7EA.2040900@nets.rwth-aachen.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Ilpo =?ISO-8859-1?Q?J=E4rvinen?= <ilpo.jarvinen@helsinki.fi>,
	Tejun Heo <tj@kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	lkml <linux-kernel@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"Fehrmann, Henning" <henning.fehrmann@aei.mpg.de>,
	Carsten Aulbert <carsten.aulbert@aei.mpg.de>
To: Lennart Schulte <lennart.schulte@nets.rwth-aachen.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <4C3EF7EA.2040900@nets.rwth-aachen.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Le jeudi 15 juillet 2010 =C3=A0 13:58 +0200, Lennart Schulte a =C3=A9cr=
it :
> I'm testing new reordering algorithms in a virtual testbed, that is t=
he=20
> nodes are emulated with xen and all the network parameters can be tun=
ed=20
> with queues.
> With one of the algorithms I also got tracebacks which include=20
> tcp_xmit_retransmit_queue. It only happens with ACK loss. The kernel=20
> version however is 2.6.31.
> When I read this thread I tried the debug patch and got the following=
:
>=20
> [ 2754.413150] NULL head, pkts 0
> [ 2754.413156] Errors caught so far 1
>=20
> Hope that is of any help.

Not sure I understand.=20

Are you saying you reproduce same tcp_xmit_retransmit_queue()  bug, wit=
h
a special tc qdisc/class droppping some ACK frames ?

Could it be some sched problem and incorrect return codes in case of
congestion ?
