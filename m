From: =?utf-8?B?TWljaGHFgiBOYXphcmV3aWN6?= <m.nazarewicz-Sze3O3UU22JBDgjK7y7TUQ@public.gmane.org>
Subject: Re: rndis gadget: Inconsistent locking
Date: Fri, 10 Dec 2010 11:01:40 +0100
Message-ID: <op.vnhss2ai7p4s8u@pikus>
References: <AANLkTik=Uui7Xk9ZfFvQQKj94ZJUJ_n+bZbTQXbe+08i@mail.gmail.com>
 <AANLkTi==UqNNzokLcLWDpjM0cqM6aXjppsi4p6ogMAqX@mail.gmail.com>
 <op.vnenkvz67p4s8u@pikus>
 <AANLkTinE1srqkpib0+8Q63XjnhRYEWaaDsX70tc_OeUm@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8;
	format=flowed	delsp=yes
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Neil Jones <neiljay-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-reply-to: <AANLkTinE1srqkpib0+8Q63XjnhRYEWaaDsX70tc_OeUm-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Thu, 09 Dec 2010 18:00:55 +0100, Neil Jones <neiljay-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org> wrot=
e:

>> Does this help: <https://patchwork.kernel.org/patch/195562/>?
>
> Yes cheers, warning gone and driver seems fine so far.
>
> has this been accepted upstream ?

No, it hasn't.  There were some concerns that this patch is invalid and=
 may
not work in some situations -- it uses an "incorrect" way of getting ne=
twork
interface statistics which, however, happens to work with g_ether.  No =
one
got to implementing the worker solution, so as of my knowledge, this is=
 the
only working patch.

--=20
Best regards,                                        _     _
| Humble Liege of Serenely Enlightened Majesty of  o' \,=3D./ `o
| Computer Science,  Micha=C5=82 "mina86" Nazarewicz       (o o)
+----[mina86*mina86.com]---[mina86*jabber.org]----ooO--(_)--Ooo--
--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
