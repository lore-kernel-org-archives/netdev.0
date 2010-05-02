From: "\"Oleg A. Arkhangelsky\"" <sysoleg@yandex.ru>
Subject: Re: Re: Kernel panic in fib_rules_lookup (kernel 2.6.32)
Date: Sun, 02 May 2010 14:46:26 +0400
Message-ID: <382091272797186@web84.yandex.ru>
References: <119601268120674@webmail87.yandex.ru> <1268154568.3113.19.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from forward9.mail.yandex.net ([77.88.61.48]:59052 "EHLO
	forward9.mail.yandex.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754355Ab0EBK4n (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 2 May 2010 06:56:43 -0400
In-Reply-To: <1268154568.3113.19.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello,

09.03.10, 17:09, "Eric Dumazet" <eric.dumazet@gmail.com>:

> Le mardi 09 mars 2010 =C3=A0 10:44 +0300, "Oleg A. Arkhangelsky" a =C3=
=A9crit :
>  > Hello,
>  >=20
>  > Got this kernel panic tomorrow. This PC is rather heavy loaded rou=
ter with BGP full view (> 300K routes).
>  > We're using FIB_TRIE. Last time we got similar panic about 1 month=
 ago. Please, let me know if you
>  > need additional information to debug (e.g. objdump). Thanks!
>  >=20
>  > Mar  9 10:08:55 bras-1 kernel: BUG: unable to handle kernel NULL p=
ointer dereference at (null)
>  > Mar  9 10:08:55 bras-1 kernel: IP: [] fib_rules_lookup+0xa2/0xd0
>  > Mar  9 10:08:55 bras-1 kernel: *pde =3D 00000000
>  > Mar  9 10:08:55 bras-1 kernel: Thread overran stack, or stack corr=
upted
> =20
>  Hmm...

Got the same panic, at the same place (fib_rules_lookup+0xa2/0xd0). Loo=
ks like the problem with NULL dereference is somewhere in list_for_each=
_entry_rcu macro. But I don't understand how this can be.

Any thoughts? :(

--=20
wbr, Oleg.
