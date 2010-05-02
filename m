From: "\"Oleg A. Arkhangelsky\"" <sysoleg@yandex.ru>
Subject: Re: Kernel panic in fib_rules_lookup (kernel 2.6.32)
Date: Sun, 02 May 2010 21:14:26 +0400
Message-ID: <355381272820467@web19.yandex.ru>
References: <119601268120674@webmail87.yandex.ru> <1268154568.3113.19.camel@edumazet-laptop> <382091272797186@web84.yandex.ru> <1272817864.2173.123.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from forward14.mail.yandex.net ([95.108.130.92]:37685 "EHLO
	forward14.mail.yandex.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757338Ab0EBRXM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 2 May 2010 13:23:12 -0400
In-Reply-To: <1272817864.2173.123.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello,

02.05.10, 18:31, "Eric Dumazet" <eric.dumazet@gmail.com>:

> Le dimanche 02 mai 2010 =C3=A0 14:46 +0400, "Oleg A. Arkhangelsky" a =
=C3=A9crit :

>  > Got the same panic, at the same place (fib_rules_lookup+0xa2/0xd0)=
=2E
>  > Looks like the problem with NULL dereference is somewhere in
>  > list_for_each_entry_rcu macro. But I don't understand how this can=
 be.
>  >=20
>  > Any thoughts? :(
>  >=20
> =20
>  Do you have any modify rules activity ?

It can be a nice clue, but unfortunately no. Moreover, we don't use rul=
es at
all. Only default template:

0:      from all lookup local
32766:  from all lookup main
32767:  from all lookup default

Also, there are no "floating" interfaces (such as ppp) on this PC. Only=
 routes
are changing periodically (Quagga with full-view BGP sessions).

--=20
wbr, Oleg.
