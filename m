From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: 2.6.34-rc1: rcu lockdep bug?
Date: Mon, 15 Mar 2010 11:04:20 +0100
Message-ID: <1268647460.3154.1.camel@edumazet-laptop>
References: <20100311134556.GA6344@linux.vnet.ibm.com>
	 <20100312.000705.225033546.davem@davemloft.net>
	 <2375c9f91003120059g771d162fxefc21beb2ab17b4d@mail.gmail.com>
	 <1268392276.3141.4.camel@edumazet-laptop>
	 <2375c9f91003120511j6f33592cl12cb2617a27351ec@mail.gmail.com>
	 <1268401058.3141.9.camel@edumazet-laptop> <20100313053356.GC3704@hack>
	 <20100313215838.GB6805@linux.vnet.ibm.com> <20100315010802.GB2735@hack>
	 <2375c9f91003142010g61841666iad53c24f39036acf@mail.gmail.com>
	 <2375c9f91003150239m1abc765bh59eb51c948eed592@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>,
	David Miller <davem@davemloft.net>, peterz@infradead.org,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: =?ISO-8859-1?Q?Am=E9rico?= Wang <xiyou.wangcong@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f209.google.com ([209.85.218.209]:46529 "EHLO
	mail-bw0-f209.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S936076Ab0COKE0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 Mar 2010 06:04:26 -0400
In-Reply-To: <2375c9f91003150239m1abc765bh59eb51c948eed592@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le lundi 15 mars 2010 =C3=A0 17:39 +0800, Am=C3=A9rico Wang a =C3=A9cri=
t :

>=20
> Ok, I think I found what lockdep really complains about, it is that w=
e took
> spin_lock in netpoll_poll_lock() which is in hardirq-enabled environm=
ent,
> later, we took another spin_lock with spin_lock_irqsave() in netpoll_=
rx(),
> so lockdep thought we broke the locking rule.
>=20
> I don't know why netpoll_rx() needs irq disabled, it looks like that =
no one
> takes rx_lock in hardirq context. So can we use spin_lock(&rx_lock)
> instead? Or am I missing something here? Eric? David?

I am a bit lost.

Could you give the complete picture, because I cannot find it in my
netdev archives.



