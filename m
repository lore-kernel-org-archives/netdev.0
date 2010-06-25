From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [RFC PATCH v2 4/5] skb: add tracepoints to freeing skb
Date: Fri, 25 Jun 2010 22:05:47 +0200
Message-ID: <1277496347.2481.12.camel@edumazet-laptop>
References: <4C2312A8.9060903@jp.fujitsu.com>
	 <4C23FF55.3090604@jp.fujitsu.com> <1277441711.2481.3.camel@edumazet-laptop>
	 <4C2456DA.8030200@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-kernel@vger.kernel.org, kaneshige.kenji@jp.fujitsu.com,
	izumi.taku@jp.fujitsu.com, netdev <netdev@vger.kernel.org>
To: Koki Sanagi <sanagi.koki@jp.fujitsu.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <4C2456DA.8030200@jp.fujitsu.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Le vendredi 25 juin 2010 =C3=A0 16:12 +0900, Koki Sanagi a =C3=A9crit :

> > You might add a trace point to skb_free_datagram_locked() too, sinc=
e it
> > contains an inlined consume_skb()
> >=20
>=20
> I think it is contrary.

I think you are _very_ wrong.

> skb_free_datagram_locked() contains consume_skb(), so tracepoint isn'=
t needed.
> Because skb_free_datagram_locked() can be traced by trace_consume_skb=
().
>=20
>=20
>=20

Koki, it would be good if you worked on net-next-2.6, so that my commen=
t
applies.

Also, not sending this kind of patches on netdev is not going to help
very much.

Who is supposed to review them on lkml and Ack them ?=20

Nobody.

Please build your future network related patches against net-next-2.6,
and send them to nedev and David Miller, the official network
maintainer, as stated in MAINTAINERS file.

NETWORKING [GENERAL]
M:      "David S. Miller" <davem@davemloft.net>
L:      netdev@vger.kernel.org
W:      http://www.linuxfoundation.org/en/Net
W:      http://patchwork.ozlabs.org/project/netdev/list/
T:      git git://git.kernel.org/pub/scm/linux/kernel/git/davem/net-2.6=
=2Egit
T:      git git://git.kernel.org/pub/scm/linux/kernel/git/davem/net-nex=
t-2.6.git
S:      Maintained
=46:      net/
=46:      include/net/
=46:      include/linux/in.h
=46:      include/linux/net.h
=46:      include/linux/netdevice.h
