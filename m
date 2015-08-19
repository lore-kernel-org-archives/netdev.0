From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: inet_hashtables.c: warning: division by zero
Date: Wed, 19 Aug 2015 09:14:31 -0700
Message-ID: <1440000871.6610.22.camel@edumazet-glaptop2.roam.corp.google.com>
References: <alpine.LRH.2.20.1508191823130.6342@math.ut.ee>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Meelis Roos <mroos@linux.ee>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f170.google.com ([209.85.192.170]:34441 "EHLO
	mail-pd0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751371AbbHSQOd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Aug 2015 12:14:33 -0400
Received: by pdbfa8 with SMTP id fa8so3178587pdb.1
        for <netdev@vger.kernel.org>; Wed, 19 Aug 2015 09:14:33 -0700 (PDT)
In-Reply-To: <alpine.LRH.2.20.1508191823130.6342@math.ut.ee>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2015-08-19 at 18:24 +0300, Meelis Roos wrote:
> Noticed this while compiling 4.2-rc7+git on i386 with gcc 4.9.2:
>=20
>   CC      net/ipv4/inet_hashtables.o
> In file included from include/linux/list.h:8:0,
>                  from include/linux/module.h:9,
>                  from net/ipv4/inet_hashtables.c:16:
> net/ipv4/inet_hashtables.c: In function =E2=80=98inet_ehash_locks_all=
oc=E2=80=99:
> net/ipv4/inet_hashtables.c:632:24: warning: division by zero [-Wdiv-b=
y-zero]
>      2 * L1_CACHE_BYTES / sizeof(spinlock_t),
>                         ^
> include/linux/kernel.h:769:17: note: in definition of macro =E2=80=98=
max_t=E2=80=99
>   type __max1 =3D (x);   \
>                  ^
>=20


This warning was fixed :=20

http://git.kernel.org/cgit/linux/kernel/git/davem/net.git/commit/?id=3D=
89e478a2aa58af2548b7f316e4d5b6bcc9eade5b
