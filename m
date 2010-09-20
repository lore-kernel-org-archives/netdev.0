From: =?utf-8?B?TWljaGHFgiBOYXphcmV3aWN6?= <m.nazarewicz@samsung.com>
Subject: Re: [PATCH] net: core: dev.c: use spin_lock_irqsave() rather than
Date: Mon, 20 Sep 2010 19:48:47 +0200
Message-ID: <op.vjceflc37p4s8u@pikus>
References: <ee14e5e38e7a5df520d902ef8a236bbe9ed206fa.1284991149.git.m.nazarewicz@samsung.com>
 <1284998621.3420.539.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8;
	format=flowed	delsp=yes
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "David S. Miller" <davem@davemloft.net>,
	linux-kernel@vger.kernel.org, linux-usb@vger.kernel.org,
	netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailout1.w1.samsung.com ([210.118.77.11]:62895 "EHLO
	mailout1.w1.samsung.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753711Ab0ITRqw convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 20 Sep 2010 13:46:52 -0400
In-reply-to: <1284998621.3420.539.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 20 Sep 2010 18:03:41 +0200, Eric Dumazet <eric.dumazet@gmail.co=
m> wrote:
> dev_get_stats(dev, &temp) is called from drivers/usb/gadget/rndis.c,
> while I suspect underlying stats are already provided in dev->stats

So, you are saying that it is likely that if I change rndis.c and repla=
ce
"dev_get_stats(net, &temp)" with plain "&net->stats" things should work
correctly (rndis.c does not use the "temp" so it's not a problem)?

I actually did that and nothing seems to crash but dunno if it didn't
make g_ether report some not fully up-to-date values or something.

--=20
Best regards,                                        _     _
| Humble Liege of Serenely Enlightened Majesty of  o' \,=3D./ `o
| Computer Science,  Micha=C5=82 "mina86" Nazarewicz       (o o)
+----[mina86*mina86.com]---[mina86*jabber.org]----ooO--(_)--Ooo--
