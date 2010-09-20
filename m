From: =?utf-8?B?TWljaGHFgiBOYXphcmV3aWN6?= <m.nazarewicz-Sze3O3UU22JBDgjK7y7TUQ@public.gmane.org>
Subject: Re: [PATCH] net: core: dev.c: use spin_lock_irqsave() rather than
Date: Mon, 20 Sep 2010 19:07:28 +0200
Message-ID: <op.vjcciqgk7p4s8u@pikus>
References: <ee14e5e38e7a5df520d902ef8a236bbe9ed206fa.1284991149.git.m.nazarewicz@samsung.com>
 <1284998621.3420.539.camel@edumazet-laptop>
 <20100920.091407.241426689.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8;
	format=flowed	delsp=yes
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-reply-to: <20100920.091407.241426689.davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Mon, 20 Sep 2010 18:14:07 +0200, David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org> =
wrote:

> From: Eric Dumazet <eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
> Date: Mon, 20 Sep 2010 18:03:41 +0200
>
>> Hmm, while your patch is technically correct, it seems strange all t=
his
>> stuff runs in hard irq context.
>
> I would much rather this RNDIS query response handler get
> scheduled to run into softirq context or similar instead.
>
> I am not applying this patch.

Eh...  I'll try to look at RNDIS than.

--=20
Best regards,                                        _     _
| Humble Liege of Serenely Enlightened Majesty of  o' \,=3D./ `o
| Computer Science,  Micha=C5=82 "mina86" Nazarewicz       (o o)
+----[mina86*mina86.com]---[mina86*jabber.org]----ooO--(_)--Ooo--
--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
