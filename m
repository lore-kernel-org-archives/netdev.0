From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Re: Kernel panic in fib_rules_lookup (kernel 2.6.32)
Date: Sun, 02 May 2010 18:31:04 +0200
Message-ID: <1272817864.2173.123.camel@edumazet-laptop>
References: <119601268120674@webmail87.yandex.ru>
	 <1268154568.3113.19.camel@edumazet-laptop>
	 <382091272797186@web84.yandex.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: "\"Oleg A. Arkhangelsky\"" <sysoleg@yandex.ru>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f219.google.com ([209.85.218.219]:41275 "EHLO
	mail-bw0-f219.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757147Ab0EBQbJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 2 May 2010 12:31:09 -0400
Received: by bwz19 with SMTP id 19so913065bwz.21
        for <netdev@vger.kernel.org>; Sun, 02 May 2010 09:31:08 -0700 (PDT)
In-Reply-To: <382091272797186@web84.yandex.ru>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le dimanche 02 mai 2010 =C3=A0 14:46 +0400, "Oleg A. Arkhangelsky" a =C3=
=A9crit :
> Hello,
>=20
> 09.03.10, 17:09, "Eric Dumazet" <eric.dumazet@gmail.com>:
>=20
> > Le mardi 09 mars 2010 =C3=A0 10:44 +0300, "Oleg A. Arkhangelsky" a =
=C3=A9crit :
> >  > Hello,
> >  >=20
> >  > Got this kernel panic tomorrow. This PC is rather heavy loaded r=
outer with BGP full view (> 300K routes).
> >  > We're using FIB_TRIE. Last time we got similar panic about 1 mon=
th ago. Please, let me know if you
> >  > need additional information to debug (e.g. objdump). Thanks!
> >  >=20
> >  > Mar  9 10:08:55 bras-1 kernel: BUG: unable to handle kernel NULL=
 pointer dereference at (null)
> >  > Mar  9 10:08:55 bras-1 kernel: IP: [] fib_rules_lookup+0xa2/0xd0
> >  > Mar  9 10:08:55 bras-1 kernel: *pde =3D 00000000
> >  > Mar  9 10:08:55 bras-1 kernel: Thread overran stack, or stack co=
rrupted
> > =20
> >  Hmm...
>=20
> Got the same panic, at the same place (fib_rules_lookup+0xa2/0xd0). L=
ooks like the problem with NULL dereference is somewhere in list_for_ea=
ch_entry_rcu macro. But I don't understand how this can be.
>=20
> Any thoughts? :(
>=20

Do you have any modify rules activity ?

I dont understand why we need synchronize_rcu() in fib_nl_delrule() but
this certainly not a bug.



